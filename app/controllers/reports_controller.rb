class ReportsController < ApplicationController
	
  def index
    @batches = Batch.all
    @departments = Department.all
    @semesters = Semester.all
    
    @department = Department.find(params[:department_id]) if params[:department_id] && params[:department_id].length != 0
    @batch = Batch.find(params[:batch_id]) if params[:batch_id] && params[:batch_id].length != 0
    @section= Section.find(params[:section_id]) if params[:section_id] && params[:section_id].length != 0
    @student= Student.find(params[:student_id]) if params[:student_id] && params[:student_id].length != 0
    @semester= Semester.find(params[:semester_id]) if params[:semester_id] && params[:semester_id].length != 0
    @exam= Exam.find(params[:exam_id]) if params[:exam_id] && params[:exam_id].length != 0
    @marks = one_section_one_semester_all_exams_with_assignments_without_arrear_entries
    return
    
    if @student && @semester && @exam
      @marks = one_student_one_semester_one_exam
    elsif @section && @semester && @exam
      @marks = one_section_one_exam_one_semester_by_students
	elsif @section && @semester
	  @marks = one_section_one_semester_all_exams_with_assignments_with_arrear_entries
    elsif @student && @semester
      #@marks = one_student_one_semester_all_exams
      @marks = one_student_one_semester_all_exams_without_assignments
    elsif @student
      @marks = one_student_all_semesters
    #we do not need the exam here. the exam should default to semester final exam
    elsif @department && @semester && @exam
      @marks = get_department_marks_with_batch    
    elsif @batch && @semester && @exam
      @marks = get_batch_marks_with_department
    elsif @batch && @department && @exam && @semester
      @marks = get_batch_marks_with_section
    elsif @batch

	elsif @section && @semester && @exam
      @marks = get_section_marks(params)
    end
    	
  end
  

  #***********************************************************************************#
  # one_student_one_semester_one_exam
  # Marksheet of a student in a particular semester for one exam. 
  # 
  # 1. Columns:- Exam and assignments for that exam.  (UT1, asgn1 for UT1, asgn2 for UT1 etc)
  # 2. Rows:- Subjects. (English(Th), Maths(Th), Data structures(Pr) etc..)
  # 3. Arrear Marks not included. Since we are selecting a section here in the filter we are not displaying
  #      the arrear marks, as the arrear subjects are taken in some other section. This has some implementation
  #      difficulty. :)
  # 4. Percentage and percentiles included for each of the mark columns.
  # 5. Sum of all exam and assignment marks (total marks) and percentage of the total marks are also
  #     included
  #TODO:
  # 1. Do we need to include the arrear marks for a particular student? (Refer #3 above). Or, we can include
  #     the arrear students in the regular students list when selecting from the filters. This will need code changes
  #     in the filter code, selectors_controller.rb. If we do that, an arrear student will be listed in all the classes 
  #      he is enrolledNeed to decided on that.
  
  #Testing status : DONE
  #------------------------------------------------------------------------------------------------------------------------------------------#

  def one_student_one_semester_one_exam
  	#this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
    table_values = []
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result.all
    #Get the exam id and assignments of that particular exam. Note that all the assignments are considered as exams.
    #The assignments are going to be yet another row as an exam would be.
    exam_ids = [@exam.id] + @exam.assignments.map {|x| x.id}
    column_keys = ['subject_name'] + exam_ids.map {|x| x.to_s} + ['total_marks', 'percentage']
    column_headings = {}

    #Populate the column_headings and column_sub_headings hash
    column_headings['subject_name'] = {'value' => "Subject", 'colspan' => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {'value' => Exam.find(exam_id).name, 'colspan' => 1}
    end
    column_headings['total_marks'] = {'value' => "Total", 'colspan' => 1}
    column_headings['percentage'] = {'value' => "Percentage", 'colspan' => 1}
    #percentiles cannot be calculated for mark_colum without the exam_id. Since we are looping through the exams
    #in the inside loop, we need to re-calculate the percentiles everytime we loop through the subject_maps. This is
    #so very inefficient. So declare the percentile as an array keyed by exam_id. Only when the percentile[exam_id]
    #is nil, we calculate the percentile, hence no recalculation needed for the same set of values.
    percentiles = []
    subject_maps.each do |ssmap|
      marks_hash = {}
      mark_col = ssmap.mark_column
      tot_val = tot_pass_marks = tot_max_marks = 0
      exam_ids.each do |exam_id|
      	#Note that we are displaying only the marks that belong to the section the student is in. We are not considering the arrear marks here.
        mark_row = Mark.search(:student_id_eq => @student.id, :semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id).result.first
        #At times, we would have associated the exams, but NOT have entered the marks. So, process the row only if 
        #a corresponding row is available.
        val = nil
        val = mark_row.send(mark_col) if mark_row
        if val
          #For every valid mark value, there should be a mark criteria. If it not there, let it throw an exception
          mc = MarkCriteria.search(:semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id, :subject_id_eq => ssmap.subject_id).result.first
          #max_marks = mc ? mc.max_marks : Mark.default_max_marks
          #pass_marks = mc ? mc.pass_marks : Mark.default_pass_marks(max_marks)
          percentages = mark_row.percentages_with_mark_columns
          percentiles[exam_id] ||= Mark.subject_percentiles_with_mark_ids(mark_col, mark_row.section_id, mark_row.semester_id, mark_row.exam_id)  
          #Make the percentile as NA if the percentile for a particular mark row is missing. Reasons may be - the student is an arrear student
          # or he is absent etc..
          percentile = percentiles[exam_id][mark_row.id] ? percentiles[exam_id][mark_row.id] : "NA"
          marks_hash[exam_id.to_s] =  { 	
          															'value' => absent_na_values_to_s(val), 'bg' => Grade.get_color_code(val) , 
          															'max_marks' => mc.max_marks,  'pass_marks' => mc.pass_marks, 
          															'percentage' => percentages[mark_col], 'percentile' => percentile
    	  														}
    	  #Add the value in each iteration to get the sum of the marks of exam and assignments.
    	  #If the student is absent or he is not applicable for this particular mark, do not add.
          tot_val = tot_val + val if (val != NA_MARK_NUM && val != ABSENT_MARK_NUM)
          #Dont add the passmarks and max marks only when the student is not applicable for this subject.
          #Even if he is absent, we should add the marks. Becasue when the student is absent, this percentage
          #should be reduced accordingly.			
          if val != NA_MARK_NUM
            tot_pass_marks = tot_pass_marks + mc.pass_marks 
            tot_max_marks = tot_max_marks + mc.max_marks 
          end
        end
      end
      #If the total marks is zero or less, make the percentage as NA
      tot_percentage = tot_max_marks > 0 ? tot_val.to_f * 100 / tot_max_marks : "NA"
      marks_hash['total_marks'] = { 'value' => tot_val }
      marks_hash['percentage'] = { 'value' => tot_percentage }
      sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
      table_values << {'subject_name' =>  {'value' => ssmap.subject.name + sub_type}}.merge(marks_hash)
    end
    return {'column_keys' => column_keys, 'column_headings' => column_headings, 'table_values' => table_values}
  end    

  #***********************************************************************************#
  # one_student_one_semester_all_exams_without_assignments
  # Marksheet of a student in a particular semester for all the exams. assignment marks are NOT included.
  # 
  # 1. Columns:- Exams(UT1, UT2, RT1 etc..)
  # 2. Rows:- Subjects. (English(Th), Maths(Th), Data structures(Pr) etc..)
  # 3. Arrear Marks not included. Since we are selecting a section here in the filter we are not displaying
  #      the arrear marks, as the arrear subjects are taken in some other section. This has some implementation
  #      difficulty. :)
  # 4. Percentage and percentiles included for each of the mark columns.

  #TODO:
  # 1. Do we need to include the arrear marks for a particular student? (Refer #3 above). Or, we can include
  #     the arrear students in the regular students list when selecting from the filters. This will need code changes
  #     in the filter code, selectors_controller.rb. If we do that, an arrear student will be listed in all the classes 
  #     he is enrolled. Need to decided on that. If a student is selected from a class where he has enrolled for
  #     arrears, we will display the subject marks only for the subject he has enrolled in the particular class (for
  #     all the exams)
  #------------------------------------------------------------------------------------------------------------------------------------------#
  def one_student_one_semester_all_exams_without_assignments
    #this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
  	table_values = [] 
    exam_ids = SecExamMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id, :exam_exam_type_eq => EXAM_TYPE_TEST).result.select('exam_id').map { |x| x.exam_id }
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result.all

    #This will have the index for the column headings hash and the table_values array
    column_keys = ['subject_name'] + exam_ids.map{ |x| x.to_s}
    column_headings = {}

    #Populate the column_headings hash. These will be the headings of the table.
    column_headings['subject_name'] = {'value' => "Subject", 'colspan' => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {'value' => Exam.find(exam_id).name, 'colspan' => 1}
    end
    
    #Get the data row wise. One row corresponds to one subject for all the exams. Take a subject
    #get the marks for all the exams. This method is not effective, but as long as it works, it is ok
    #now. Need to see if we can improve this.
    subject_maps.each do |ssmap|
      #to hold all the data of one row without the subject name.
      marks_hash = {}
      mark_col = ssmap.mark_column
      #loop through each of the exams and get the mark for this particular subject - mark_col
      exam_ids.each do |exam_id|
        mark_row = Mark.search(:student_id_eq => @student.id, :semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id).result.first
        #At times, we would have associated the exams, but NOT have entered the marks. So, process the row only if 
        #a corresponding row is available.        
        if mark_row && mark_row.send(mark_col)
          #For every valid mark value there should be a mark criteria. If it is not present, let it throw an exception.
          mc = MarkCriteria.search(:semester_id_eq => mark_row.semester_id, :section_id_eq => mark_row.section_id, :exam_id_eq => exam_id, :subject_id_eq => ssmap.subject_id).result.first
          #pass_marks = mc ? mc.pass_marks : 0
          #max_marks = mc ? mc.max_marks : 0
          percentages = mark_row.percentages_with_mark_columns
          #Definition in mark.rb => self.subject_percentiles_with_mark_ids(col_name, section_id, semester_id, exam_id)
          percentiles = Mark.subject_percentiles_with_mark_ids(mark_col, mark_row.section_id, mark_row.semester_id, exam_id)  
          marks_hash[exam_id.to_s] =  { 	
          															'value' => absent_na_values_to_s(mark_row.send(mark_col)), 
                                        'bg' => Grade.get_color_code(mark_row.send(mark_col)) , 
          															'max_marks' => mc.max_marks,  'pass_marks' => mc.pass_marks, 
          															'percentage' => percentages[mark_col], 'percentile' => percentiles[mark_row.id]
    	  		  												  }
	    end
      end
      sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
      table_values << {'subject_name' =>  {'value' => ssmap.subject.name + sub_type}}.merge(marks_hash)
    end
    return {'column_keys' => column_keys, 'column_headings' => column_headings, 'table_values' => table_values}
  end  
  
  
  #***********************************************************************************#
  # one_student_one_semester_all_exams_including_assignments
  # Marksheet of a student in a particular semester for all the exams (exam marks include the assignment marks)
  # 
  # 1. Columns:- Exams(UT1, UT2, RT1 etc..)
  # 2. Rows:- Subjects. (English(Th), Maths(Th), Data structures(Pr) etc..)
  # 3. Arrear Marks not included. Since we are selecting a section here in the filter we are not displaying
  #      the arrear marks, as the arrear subjects are taken in some other section. This has some implementation
  #      difficulty. :)
  # 4. Percentage and percentiles NOT included for each of the mark columns. We do not have helper modules
  #      in mark.rb for calcuating the percentages and percentiles for subject marks including the assignments.

  #TODO:
  # 1. Do we need to include the arrear marks for a particular student? (Refer #3 above). Or, we can include
  #     the arrear students in the regular students list when selecting from the filters. This will need code changes
  #     in the filter code, selectors_controller.rb. If we do that, an arrear student will be listed in all the classes 
  #     he is enrolled. Need to decided on that. If a student is selected from a class where he has enrolled for
  #     arrears, we will display the subject marks only for the subject he has enrolled in the particular class (for
  #     all the exams)
  # 2. Decide whether we need to have percentage and percentiles for the subject marks. Refer #4 above. If
  #      need be, modules have to be written inside mark.rb file.
  #------------------------------------------------------------------------------------------------------------------------------------------#
  def one_student_one_semester_all_exams_including_assignments
    #this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
  	table_values = [] 
    exam_ids = SecExamMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id, :exam_exam_type_eq => EXAM_TYPE_TEST).result.select('exam_id').map { |x| x.exam_id }
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result.all

    #This will have the index for the column headings hash and the table_values array
    column_keys = ['subject_name'] + exam_ids.map{ |x| x.to_s}
    column_headings = {}

    #Populate the column_headings hash. These will be the headings of the table.
    column_headings['subject_name'] = {'value' => "Subject", :colspan => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {'value' => Exam.find(exam_id).name, :colspan => 1}
    end
    
    #Get the data row wise. One row corresponds to one subject for all the exams. Take a subject
    #get the marks for all the exams. This method is not effective, but as long as it works, it is ok
    #now. Need to see if we can improve this.
    subject_maps.each do |ssmap|
      #to hold all the data of one row without the subject name.
      marks_hash = {}
      mark_col = ssmap.mark_column
      #loop through each of the exams and get the mark for this particular subject - mark_col
      exam_ids.each do |exam_id|
      	mark_rows = []
        temp_row = Mark.search(:student_id_eq => @student.id, :semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id).result.first
        if temp_row
          mark_rows << temp_row
          mark_rows += temp_row.assignments if !temp_row.assignments.empty?
        end
        #At times, we would have associated the exams, but NOT have entered the marks. So, process the row only if 
        #a corresponding row is available.        
        tot_marks = tot_pass_marks = tot_max_marks = 0
        mark_rows.each do |mark_row|
          if mark_row
          	#Careful! We should not use exam_id for the filter, but use mark_row.exam_id.  We are  also reading the marks of the assignments and exam_id will always have the base exam id.
            val = mark_row.send(mark_col)
          	mc = MarkCriteria.search(:semester_id_eq => mark_row.semester_id, :section_id_eq => mark_row.section_id, :exam_id_eq => mark_row.exam_id, :subject_id_eq => ssmap.subject_id).result.first
            pass_marks = mc ? mc.pass_marks : 0
            max_marks = mc ? mc.max_marks : 0
            tot_marks += val if val && val != ABSENT_MARK_NUM && val != NA_MARK_NUM
            tot_pass_marks += pass_marks
            tot_max_marks += max_marks
	      end
        end
        marks_hash[exam_id.to_s] =  { 	
        															'value' => tot_marks, 'bg' => Grade.get_color_code(tot_marks) , 
        															'max_marks' => tot_max_marks,  'pass_marks' => tot_pass_marks, 
        															'percentage' => "NA", 'percentile' => "NA"
    			  												  }        
      end
      sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
      table_values << {'subject_name' =>  {'value' => ssmap.subject.name + sub_type}}.merge(marks_hash)
    end
    return {'column_keys' => column_keys, 'column_headings' => column_headings, 'table_values' => table_values}
  end  
    

  #***********************************************************************************#
  # one_student_all_semesters
  # Marksheet of a student in all the semesters applicable. Note that this marksheet will contain
  # only the final exam marks
  # 
  # 1. Columns:- Subjects. Each of the semester will have different set of subjects. So, there wont be
  #                          any column heading, but the subject name will be displayed in each of the cell.
  # 2. Rows:- Semesters.
  # 3. Arrear Marks not included. Since we are selecting a section here in the filter we are not displaying
  #      the arrear marks, as the arrear subjects are taken in some other section. This has some implementation
  #      difficulty. :)
  # 4. Percentage and percentiles included for each of the mark cells.
  #TODO:
  # 1. Do we need to include the arrear marks for a particular student? (Refer #3 above). Or, we can include
  #     the arrear students in the regular students list when selecting from the filters. This will need code changes
  #     in the filter code, selectors_controller.rb. If we do that, an arrear student will be listed in all the classes 
  #      he is enrolledNeed to decided on that.
  #------------------------------------------------------------------------------------------------------------------------------------------#

  def one_student_all_semesters
  #this will have all the rows except the heading row. Each of the rows will be hash keyed by the subject ids except the semester name.
  	table_values = [] 
  	#Take out all the semester ids for the current student's section.
    semester_ids = @student.section.sec_sub_maps.order('semester_id ASC').select('semester_id').map { |x| x.semester_id}.uniq
    #One loop for each row.
    semester_ids.each do |sem_id|
      final_exam = @student.section.sec_exam_maps.joins(:exam).where("exams.finals = ?", true).first
      #Check if final exam is available for the section + semester. If not, skip this loop.
      if final_exam
        final_exam_id = final_exam.exam_id	
        mark_row = Mark.search(:student_id_eq => @student.id, :semester_id_eq => sem_id, :section_id_eq => @student.section.id, :exam_id_eq => final_exam_id).result.first
        #Check if a mark row is availble for the final exam for this semester + section. If yes, proceed, otherwise, bail out.
        if mark_row
          percentages = mark_row.percentages_with_mark_columns
          subject_maps = SecSubMap.search(:section_id_eq => @student.section.id, :semester_id_eq => sem_id).result.all
          marks_hash = {}
          #One loop for one column (subject)
          subject_maps.each do |sub_map|
            if mark_row.send(sub_map.mark_column)
              percentiles = Mark.subject_percentiles_with_mark_ids(sub_map.mark_column, mark_row.section_id, mark_row.semester_id, mark_row.exam_id)  
              sub_type = sub_map.subject.lab ? " (Pr) " : " (Th) "
              marks_hash[sub_map.subject_id] =  { 	
              																		'value' => mark_row.send(sub_map.mark_column), 'bg' => Grade.get_color_code(mark_row.send(sub_map.mark_column)) , 
              																		'percentage' => percentages[sub_map.mark_column], 'percentile' => percentiles[mark_row.id],
            																		'subject_name' =>  sub_map.subject.name + sub_type
    	      																	}
    	    end
          end #End-loop subject_maps.each do |sub_map|
          #include other columns apart from the subjects. TODO: make sure these columns are sufficient.
          marks_hash['total'] = mark_row.send('total')
          marks_hash['arrears_count'] = mark_row.send("arrears_count")
          marks_hash['passed_count'] = mark_row.send("passed_count")
          marks_hash['total_credits'] = mark_row.send("total_credits")
          marks_hash['weighed_total_percentage'] = mark_row.send("weighed_total_percentage")
          table_values << {:semester_name =>  Semester.find(sem_id).name}.merge(marks_hash)      
        end # End-if if mark_row
      end #End-if if final_exam
    end # End-loop semester_ids.each do |sem_id|
    return {'table_values' => table_values}
  end
  
  #***********************************************************************************#
  # one_section_one_exam_one_semester_by_students
  # Marksheet of an entire section in a particular exam + semester (marks of all students in a section)
  # 
  # 1. Columns:- Subjects, total, percentage, total_credits etc.. 
  # 2. Rows:- Students
  # 3. Arrear Marks not included. Since we are selecting a section here in the filter we are not displaying
  #      the arrear marks, as the arrear subjects are taken in some other section. This has some implementation
  #      difficulty. :)
  # 4. Percentage and percentiles included for each of the mark cells, total, weighed_total_percentage, and
  #      weighed_total_marks_percentage.
  #TODO:
  # 1. Do we need to include the arrear marks for a particular student? (Refer #3 above). Or, we can include
  #     the arrear students in the regular students list when selecting from the filters. This will need code changes
  #     in the filter code, selectors_controller.rb. If we do that, an arrear student will be listed in all the classes 
  #      he is enrolledNeed to decided on that.
  #------------------------------------------------------------------------------------------------------------------------------------------#  
  def one_section_one_exam_one_semester_by_students
  	#this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
    table_values = []
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result
    #Take out all the subjects for this section.
    subject_ids = subject_maps.order('subject_id ASC').select("subject_id").map{ |x| x.subject_id}.uniq
    #There are the additional columns that are displayed apart from the subject names. 
    #TODO: Check if more columns are necessary.
    other_columns = ['total_credits','total', 'weighed_total_percentage', 'weighed_pass_marks_percentage', 'passed_count', 'arrears_count']
    column_keys = ['student_name'] + subject_ids.map {|x| x.to_s} + other_columns
    column_headings = {}
    #This will contain the percentiles of all the subjects and other columns. each of the element in the hash is keyed by mark_column(subject name alias), 
    # and will have a hash. This has will have the percentiles keyed by the mark_ids. Refer subject_percentiles_with_mark_ids in mark.rb
    #that hash 
    percentiles = {}
    #Populate the column_headings
    column_headings['student_name'] = {'value' => "Student", :colspan => 1 } 
    subject_ids.each do |subject_id|
      mc = MarkCriteria.search(:semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => @exam.id, :subject_id_eq => subject_id).result.first
      credits = subject_maps.for_subject(subject_id).first.credits
      sub_type = Subject.find(subject_id).lab ? " (Pr) " : " (Th) "
      column_headings[subject_id.to_s] = {'value' => Subject.find(subject_id).name + sub_type, 'credits' => credits,
                                          'max_marks' => mc.max_marks, 'pass_marks' => mc.pass_marks, :colspan => 1}
      #Calculate the percentiles for the subjects here itself. If you bring this calculation into the student's loop, it will be
      #too inefficient.
      mark_col = subject_maps.search(:subject_id_eq => subject_id).result.first.mark_column
      #debugger
      percentiles[mark_col] = Mark.subject_percentiles_with_mark_ids(mark_col, @section.id, @semester.id, @exam.id)  
    end
    #Calcuate the percentiles for only the total and the percentages. No need to calculate for passed/arrears_count etc..
    ['total', 'weighed_total_percentage', 'weighed_pass_marks_percentage'].each do |column|
      percentiles[column] = Mark.subject_percentiles_with_mark_ids(column, @section.id, @semester.id, @exam.id)  
	end
	#Populate the column headings for the other columns here.
    column_headings['total_credits'] = {'value' => "Total Credits", :colspan => 1}
    column_headings['total'] = {'value' => "Total", :colspan => 1}
    column_headings['weighed_total_percentage'] = {'value' => "Weighed Total Percentage", :colspan => 1}
    column_headings['weighed_pass_marks_percentage'] = {'value' => "Weighed Pass Marks Percentage", :colspan => 1}
    column_headings['passed_count'] = {'value' => "Passed Count", :colspan => 1}
    column_headings['arrears_count'] = {'value' => "Arrears Count", :colspan => 1}        
    #One iteration for each student (one iteration for one row in the table)
    @section.students.each do |student|
      marks_hash = {}
      #Mark for this particular student in the given conditions
      mark_row = Mark.search(:student_id_eq => student.id, :semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => @exam.id).result.first
      #One iteration for each of the columns (columns are subjects)
      subject_ids.each do |subject_id|
      	#Use the subject_maps association already built to get the mark_column
      	mark_col = subject_maps.search(:subject_id_eq => subject_id).result.first.mark_column
        if mark_row && mark_row.send(mark_col) 
          mc = MarkCriteria.search(:semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => @exam.id, :subject_id_eq => subject_id).result.first
          #pass_marks = mc ? mc.pass_marks : 0
          #max_marks = mc ? mc.max_marks : 0
          percentages = mark_row.percentages_with_mark_columns
          marks_hash[subject_id.to_s] =  { 	
          															'value' => absent_na_values_to_s(mark_row.send(mark_col)), 'bg' => Grade.get_color_code(mark_row.send(mark_col)) , 
          															'max_marks' => mc.max_marks,  'pass_marks' => mc.pass_marks, 
          															'percentage' => percentages[mark_col], 'percentile' => percentiles[mark_col][mark_row.id]
    	  														    }
        end
      end
      #Include the other columns in the hash only if a valid mark row is present.
      if mark_row
      	#Colums for which the percentiles have been already calculated.
      	['total', 'weighed_total_percentage', 'weighed_pass_marks_percentage'].each do |column|
      	  marks_hash[column] = { 'value' => mark_row.send(column), 'percentile' => percentiles[column][mark_row.id] }
  	 	end
  	 	#Columns for which the percentiles are NA
  	    ['total_credits', 'passed_count', 'arrears_count'].each do |column|
      	  marks_hash[column] = { 'value' => mark_row.send(column) }
  	   	end
      end
      #Even if there are no mark rows, the students name alone will be displayed in the mark list. 
      table_values << {'student_name' =>  {'value' => student.name}}.merge(marks_hash)
    end
    return {'column_keys' => column_keys, 'column_headings' => column_headings, 'table_values' => table_values}
  end        
  
  #***********************************************************************************#
  # one_section_one_semester_all_exams_with_assignments_with_arrear_entries
  # Marksheet of an entire section in a semester. All the exams marks will be presented.
  # with assignmets. The average of all students' marks is displayed. Note that the average
  # includes the arrear students' marks also. If the class average should be calculated without
  # the arrear students use - one_section_one_semester_all_exams_with_assignments_without_arrear_entries
  
  # 1. Columns:- Exams (exam1, assgn1 for exam1, assgn2 for exam1, exam2, assgn for exam2 etc..)
  # 2. Rows:- Subjects. (Each row will have a particular subject mark in each of the exams) +
  #      Non subject columns in marks table such as total, average etc..
  # 3. Arrear Marks included. The average for a exam + subject is calculated with the arrear students' marks.

  #------------------------------------------------------------------------------------------------------------------------------------------#    
  
  def one_section_one_semester_all_exams_with_assignments_with_arrear_entries
    #this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
  	table_values = [] 
  	exam_ids = []
    #exam_ids = SecExamMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id, :exam_exam_type_eq => EXAM_TYPE_TEST).result.select('exam_id').map { |x| x.exam_id }
    SecExamMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id, :exam_exam_type_eq => EXAM_TYPE_TEST).result.select('exam_id').each do |semap|
      exam_ids << semap.exam_id
      semap.exam.assignments.each do |asgn|
        exam_ids << asgn.id	
      end
    end
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result.all

    #This will have the index for the column headings hash and the table_values array
    column_keys = ['subject_name'] + exam_ids.map{ |x| x.to_s}
    column_headings = {}

    #Populate the column_headings hash. These will be the headings of the table.
    column_headings['subject_name'] = {'value' => "Subject", :colspan => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {'value' => Exam.find(exam_id).name, :colspan => 1}
    end
    
    total_and_average = {}
    #Get the data row wise. One row corresponds to one subject for all the exams. Take a subject
    #get the marks for all the exams. This method is not effective, but as long as it works, it is ok
    #now. Need to see if we can improve this.
    subject_maps.each do |ssmap|
      #to hold all the data of one row without the subject name.
      marks_hash = {}
      mark_col = ssmap.mark_column
      #loop through each of the exams and get the mark for this particular subject - mark_col
      exam_ids.each do |exam_id|
        mc = MarkCriteria.search(:semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id, :subject_id_eq => ssmap.subject_id).result.first
      	mark_rows = []
      	total_and_average[exam_id.to_s] ||= Mark.columns_total_and_average_for_section_with_arrear_entries_in_semex(@section.id, @semester.id, exam_id)
        marks_hash[exam_id.to_s] =  { 	
                                      'value' => total_and_average[exam_id.to_s][mark_col]['average'], #Make the average as the default value
        															'total' => total_and_average[exam_id.to_s][mark_col]['total'], 
        															'average' => total_and_average[exam_id.to_s][mark_col]['average'], 
        															'count' => total_and_average[exam_id.to_s][mark_col]['count'],
                                      'max_marks' => mc.max_marks, 'pass_marks' => mc.pass_marks,
                                      'average_percentage' => total_and_average[exam_id.to_s][mark_col]['average'].to_f * 100 / mc.max_marks
    			  												}        
      end
      sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
      table_values << {'subject_name' =>  {'value' => ssmap.subject.name + sub_type} }.merge(marks_hash)
    end
    
    NON_SUB_COLUMNS.each do |non_sub_column|
      #to hold all the data of one row without the subject name.
      marks_hash = {}
      mark_col = non_sub_column
      #loop through each of the exams and get the mark for this particular subject - mark_col
      exam_ids.each do |exam_id|
      	mark_rows = []
      	total_and_average[exam_id.to_s] ||= Mark.columns_total_and_average_for_section_with_arrear_entries_in_semex(@section.id, @semester.id, exam_id)
        marks_hash[exam_id.to_s] =  { 	
                                      'value' => total_and_average[exam_id.to_s][mark_col]['average'], #Make the average as the default value
        															'total' => total_and_average[exam_id.to_s][mark_col]['total'], 
        															'average' => total_and_average[exam_id.to_s][mark_col]['average'], 
        															'count' => total_and_average[exam_id.to_s][mark_col]['count']
    			  												  }        
      end
      table_values << {'subject_name' =>  {'value' => NON_SUB_COLUMNS_DISPLAY_NAMES[mark_col]} }.merge(marks_hash)
    end
    return {'column_keys' => column_keys, 'column_headings' => column_headings, 'table_values' => table_values}
  end
  
 
  #***********************************************************************************#
  # one_section_one_semester_all_exams_with_assignments_without_arrear_entries
  # Marksheet of an entire section in a semester. All the exams marks will be presented.
  # with assignments. The average of all students' marks is displayed. Note that the average
  # DOES NOT include  the arrear students' marks. If the class average should be calculated with
  # the arrear students use - one_section_one_semester_all_exams_with_assignments_with_arrear_entries
  
  # 1. Columns:- Exams (exam1, assgn1 for exam1, assgn2 for exam1, exam2, assgn for exam2 etc..)
  # 2. Rows:- Subjects. (Each row will have a particular subject mark in each of the exams) +
  #      Non subject columns in marks table such as total, average etc..
  # 3. Arrear Marks NOT included. The average for a exam + subject is calculated without the arrear student
  #     marks

  #------------------------------------------------------------------------------------------------------------------------------------------#    
  
  def one_section_one_semester_all_exams_with_assignments_without_arrear_entries
    #this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
  	table_values = [] 
  	exam_ids = []
    #exam_ids = SecExamMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id, :exam_exam_type_eq => EXAM_TYPE_TEST).result.select('exam_id').map { |x| x.exam_id }
    SecExamMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id, :exam_exam_type_eq => EXAM_TYPE_TEST).result.select('exam_id').each do |semap|
      exam_ids << semap.exam_id
      semap.exam.assignments.each do |asgn|
        exam_ids << asgn.id	
      end
    end
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result.all

    #This will have the index for the column headings hash and the table_values array
    column_keys = ['subject_name'] + exam_ids.map{ |x| x.to_s}
    column_headings = {}

    #Populate the column_headings hash. These will be the headings of the table.
    column_headings['subject_name'] = {'value' => "Subject", :colspan => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {'value' => Exam.find(exam_id).name, :colspan => 1}
    end
    
    total_and_average = {}
    #Get the data row wise. One row corresponds to one subject for all the exams. Take a subject
    #get the marks for all the exams. This method is not effective, but as long as it works, it is ok
    #now. Need to see if we can improve this.
    subject_maps.each do |ssmap|
      #to hold all the data of one row without the subject name.
      marks_hash = {}
      mark_col = ssmap.mark_column
      #loop through each of the exams and get the mark for this particular subject - mark_col
      exam_ids.each do |exam_id|
        mc = MarkCriteria.search(:semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id, :subject_id_eq => ssmap.subject_id).result.first
      	mark_rows = []
      	total_and_average[exam_id.to_s] ||= Mark.columns_total_and_average_for_section_without_arrear_entries_in_semex(@section.id, @semester.id, exam_id)
        marks_hash[exam_id.to_s] =  { 	
                                      'value' => total_and_average[exam_id.to_s][mark_col]['average'], #Make the average as the default value
        															'total' => total_and_average[exam_id.to_s][mark_col]['total'], 
        															'average' => total_and_average[exam_id.to_s][mark_col]['average'], 
        															'count' => total_and_average[exam_id.to_s][mark_col]['count'],
                                      'max_marks' => mc.max_marks, 'pass_marks' => mc.pass_marks,
                                      'average_percentage' => total_and_average[exam_id.to_s][mark_col]['average'].to_f * 100 / mc.max_marks
    			  												}         
      end
      sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
      table_values << {'subject_name' =>  {'value' => ssmap.subject.name + sub_type} }.merge(marks_hash)
    end
    
    NON_SUB_COLUMNS.each do |non_sub_column|
      #to hold all the data of one row without the subject name.
      marks_hash = {}
      mark_col = non_sub_column
      #loop through each of the exams and get the mark for this particular subject - mark_col
      exam_ids.each do |exam_id|
      	mark_rows = []
      	total_and_average[exam_id.to_s] ||= Mark.columns_total_and_average_for_section_without_arrear_entries_in_semex(@section.id, @semester.id, exam_id)
        marks_hash[exam_id.to_s] =  { 	
                                      'value' => total_and_average[exam_id.to_s][mark_col]['average'], #Make the average as the default value
        															'total' => total_and_average[exam_id.to_s][mark_col]['total'], 
        															'average' => total_and_average[exam_id.to_s][mark_col]['average'], 
        															'count' => total_and_average[exam_id.to_s][mark_col]['count']
    			  												  }        
      end
      table_values << {'subject_name' =>  {'value' => NON_SUB_COLUMNS_DISPLAY_NAMES[mark_col]} }.merge(marks_hash)
    end
    
    return {'column_keys' => column_keys, 'column_headings' => column_headings, 'table_values' => table_values}
  end  
    
end
