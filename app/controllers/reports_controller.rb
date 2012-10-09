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
    
    if @student && @semester && @exam
      @marks = one_student_one_semester_one_exam
    elsif @student && @semester
      #@marks = one_student_one_semester_all_exams
      @marks = one_student_one_semester_all_exams_with_assignments
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
  
  def get_section_marks(params)
  	ret_val = []
    marks = Mark.for_section(@section.id).for_semester(@semester.id).for_exam(@exam.id)
    marks.each do |mark_row|
      temp_hash = {}
      total_credits = 0
      total_percentage=0
      temp_hash['student_name'] = mark_row.student.name
      temp_hash['subjects'] = {}
      percentages = mark_row.percentages_with_mark_columns
      percentiles = {}
      weighed_total_percentiles = Mark.weighed_total_percentiles_with_mark_ids(@section.id, @semester.id, @exam.id)
      @section.sec_sub_maps.order('subject_id ASC').each do |ssmap| 
	    percentiles[ssmap.mark_column] = Mark.subject_percentiles_with_mark_ids(ssmap.mark_column, @section.id, @semester.id, @exam.id)
      end      
      @section.sec_sub_maps.order('subject_id ASC').each do |ssmap| 
      	temp_hash['subjects'][ssmap.mark_column] = {}
      	m = mark_row.send(ssmap.mark_column.to_sym)
      	if m == NA_MARK_NUM || m == ABSENT_MARK_NUM
          temp_hash['subjects'][ssmap.mark_column]['marks'] = m == ABSENT_MARK_NUM ? "A" : "NA"
    	  temp_hash['subjects'][ssmap.mark_column]['percentage'] = "NA"
    	  temp_hash['subjects'][ssmap.mark_column]['percentile'] = "NA"
    	  temp_hash['subjects'][ssmap.mark_column]['bg'] = "none"
        else
          temp_hash['subjects'][ssmap.mark_column]['marks'] = mark_row.send(ssmap.mark_column.to_sym)
    	  temp_hash['subjects'][ssmap.mark_column]['percentage'] = percentages[ssmap.mark_column]
    	  temp_hash['subjects'][ssmap.mark_column]['percentile'] = percentiles[ssmap.mark_column][mark_row.id]
    	  temp_hash['subjects'][ssmap.mark_column]['bg'] = Grade.get_color_code(percentages[ssmap.mark_column])          
        end

    	temp_hash['subjects'][ssmap.mark_column]['credits'] = ssmap.credits
      end
      temp_hash['total'] = {'marks' => mark_row.total, 'bg' => Grade.get_color_code(mark_row.total) }
      temp_hash['arrears'] = mark_row.get_arrear_subjects_count
      temp_hash['passed'] = mark_row.get_passed_subjects_count
      temp_hash['weighed_total_percentage'] = mark_row.weighed_total_percentage
      temp_hash['weighed_total_percentile'] = weighed_total_percentiles[mark_row.id]
      ret_val << temp_hash
    end
    return ret_val
  end
  
  #batch, department, semester and exam should be valid.
  #For now, we are considering any exam by editing the url.
  #The exam should default to semester final exam.
  def get_batch_marks_with_section
    ret_val = []
    sections = Section.for_department(@department.id).for_batch(@batch.id).all
    sections.each do |section|
      th = {}
      mark_rel = Mark.for_section(section.id).for_semester(@semester.id).for_exam(@exam.id)

      reg_students = section.students.count
      arr_students = ArrearStudent.for_section(section.id).for_semester(@semester.id).count
      total_students = reg_students + arr_students
      
      scripts_passed = Mark.total_on_column(mark_rel, "passed_count")
      scripts_failed = Mark.total_on_column(mark_rel, "arrears_count")
      total_scripts = scripts_passed + scripts_failed

      th['section_name'] = section.name
      th['students_count'] = {:regular_students => reg_students, :arrear_students => arr_students, :total => total_students }
      th['scripts'] = {	:passed => scripts_passed, 
      								:failed => scripts_failed, 
      								:total => scripts_passed + scripts_failed,
      								:pass_percentage => (scripts_passed.to_f / total_scripts) * 100,
      								:fail_percentage => 100 - ((scripts_failed.to_f / total_scripts) * 100)
  								}
      th['all_clear_students'] = mark_rel.where{arrears_count == 0}.count
      th['all_clear_students_percentage'] = (th['all_clear_students'].to_f / total_students ) * 100
      th['average_weighed_total_percentage'] = Mark.total_on_column(mark_rel, "weighed_total_percentage").to_f / total_students
      ret_val << th
    end
    return ret_val
  end
  
  
  def get_department_marks_with_batch
    ret_val = []
    batches = Batch.all
    batches.each do |batch|
      th = {}
      mark_rel = Mark.search(:section_batch_id_eq => batch.id, :exam_id_eq => @exam.id, :semester_id_eq => @semester.id).result

      reg_students = Student.search(:section_batch_id_eq => batch.id).result.count
      arr_students = ArrearStudent.search(:section_batch_id_eq => batch.id).result.count
      total_students = reg_students + arr_students
      
      scripts_passed = Mark.total_on_column(mark_rel, "passed_count")
      scripts_failed = Mark.total_on_column(mark_rel, "arrears_count")
      total_scripts = scripts_passed + scripts_failed

      th['batch_name'] = batch.name
      th['students_count'] = {:regular_students => reg_students, :arrear_students => arr_students, :total => total_students }
      th['scripts'] = {	:passed => scripts_passed, 
      								:failed => scripts_failed, 
      								:total => scripts_passed + scripts_failed,
      								:pass_percentage => (scripts_passed.to_f / total_scripts) * 100,
      								:fail_percentage => 100 - ((scripts_failed.to_f / total_scripts) * 100)
  								}
      th['all_clear_students'] = mark_rel.where{arrears_count == 0}.count
      th['all_clear_students_percentage'] = (th['all_clear_students'].to_f / total_students ) * 100
      th['average_weighed_total_percentage'] = Mark.total_on_column(mark_rel, "weighed_total_percentage").to_f / total_students
      ret_val << th
    end
    return ret_val    	
  end  
  
  def get_batch_marks_with_department
    ret_val = []
    departments = Department.all
    departments.each do |department|
      th = {}
      mark_rel = Mark.search(:section_department_id_eq => department.id, :exam_id_eq => @exam.id, :semester_id_eq => @semester.id).result

      reg_students = Student.search(:section_department_id_eq => department.id).result.count
      arr_students = ArrearStudent.search(:section_batch_id_eq => department.id).result.count
      total_students = reg_students + arr_students
      
      scripts_passed = Mark.total_on_column(mark_rel, "passed_count")
      scripts_failed = Mark.total_on_column(mark_rel, "arrears_count")
      total_scripts = scripts_passed + scripts_failed

      th['batch_name'] = department.name
      th['students_count'] = {:regular_students => reg_students, :arrear_students => arr_students, :total => total_students }
      th['scripts'] = {	:passed => scripts_passed, 
      								:failed => scripts_failed, 
      								:total => scripts_passed + scripts_failed,
      								:pass_percentage => (scripts_passed.to_f / total_scripts) * 100,
      								:fail_percentage => 100 - ((scripts_failed.to_f / total_scripts) * 100)
  								}
      th['all_clear_students'] = mark_rel.where{arrears_count == 0}.count
      th['all_clear_students_percentage'] = (th['all_clear_students'].to_f / total_students ) * 100
      th['average_weighed_total_percentage'] = Mark.total_on_column(mark_rel, "weighed_total_percentage").to_f / total_students
      ret_val << th
    end
    return ret_val    	
  end

  #***********************************************************************************#
  # one_student_one_semester_all_exams
  # Marksheet of a student in a particular semester for all the exams. assignment marks are not included.
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
  def one_student_one_semester_all_exams
    #this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
  	table_values = [] 
    exam_ids = SecExamMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id, :exam_exam_type_eq => EXAM_TYPE_TEST).result.select('exam_id').map { |x| x.exam_id }
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result.all

    #This will have the index for the column headings hash and the table_values array
    column_keys = ['subject_name'] + exam_ids.map{ |x| x.to_s}
    column_headings = {}

    #Populate the column_headings hash. These will be the headings of the table.
    column_headings['subject_name'] = {:display_name => "Subject", :colspan => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {:display_name => Exam.find(exam_id).name, :colspan => 1}
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
          mc = MarkCriteria.search(:semester_id_eq => mark_row.semester_id, :section_id_eq => mark_row.section_id, :exam_id_eq => exam_id, :subject_id_eq => ssmap.subject_id).result.first
          pass_marks = mc ? mc.pass_marks : 0
          max_marks = mc ? mc.max_marks : 0
          percentages = mark_row.percentages_with_mark_columns
          #Definition in mark.rb => self.subject_percentiles_with_mark_ids(col_name, section_id, semester_id, exam_id)
          percentiles = Mark.subject_percentiles_with_mark_ids(mark_col, mark_row.section_id, mark_row.semester_id, exam_id)  
          marks_hash[exam_id.to_s] =  { 	
          															:value => mark_row.send(mark_col), :bg => Grade.get_color_code(mark_row.send(mark_col)) , 
          															:max_marks => max_marks,  :pass_marks => pass_marks, 
          															:percentage => percentages[mark_col], :percentile => percentiles[mark_row.id]
    	  		  												  }
	    end
      end
      sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
      table_values << {:subject_name =>  ssmap.subject.name + sub_type}.merge(marks_hash)
    end
    return {:column_keys => column_keys, :column_headings => column_headings, :table_values => table_values}
  end  
  
  
  #***********************************************************************************#
  # one_student_one_semester_all_exams_with_assignments
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
  def one_student_one_semester_all_exams_with_assignments
    #this will have all the rows except the heading row. Each of the rows will be hash keyed by the values in column_keys.
  	table_values = [] 
    exam_ids = SecExamMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id, :exam_exam_type_eq => EXAM_TYPE_TEST).result.select('exam_id').map { |x| x.exam_id }
    subject_maps = SecSubMap.search(:section_id_eq => @section.id, :semester_id_eq => @semester.id).result.all

    #This will have the index for the column headings hash and the table_values array
    column_keys = ['subject_name'] + exam_ids.map{ |x| x.to_s}
    column_headings = {}

    #Populate the column_headings hash. These will be the headings of the table.
    column_headings['subject_name'] = {:display_name => "Subject", :colspan => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {:display_name => Exam.find(exam_id).name, :colspan => 1}
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
          	mc = MarkCriteria.search(:semester_id_eq => mark_row.semester_id, :section_id_eq => mark_row.section_id, :exam_id_eq => mark_row.exam_id, :subject_id_eq => ssmap.subject_id).result.first
            pass_marks = mc ? mc.pass_marks : 0
            max_marks = mc ? mc.max_marks : 0
            tot_marks += mark_row.send(mark_col) if mark_row.send(mark_col)
            tot_pass_marks += pass_marks
            tot_max_marks += max_marks
	      end
        end
        marks_hash[exam_id.to_s] =  { 	
        															:value => tot_marks, :bg => Grade.get_color_code(tot_marks) , 
        															:max_marks => tot_max_marks,  :pass_marks => tot_pass_marks, 
        															:percentage => "NA", :percentile => "NA"
    			  												  }        
      end
      sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
      table_values << {:subject_name =>  ssmap.subject.name + sub_type}.merge(marks_hash)
    end
    return {:column_keys => column_keys, :column_headings => column_headings, :table_values => table_values}
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
    column_headings['subject_name'] = {:display_name => "Subject", :colspan => 1 } 
    exam_ids.each do |exam_id|
      column_headings[exam_id.to_s] = {:display_name => Exam.find(exam_id).name, :colspan => 1}
    end
    column_headings['total_marks'] = {:display_name => "Total", :colspan => 1}
    column_headings['percentage'] = {:display_name => "Percentage", :colspan => 1}
    
    subject_maps.each do |ssmap|
      marks_hash = {}
      mark_col = ssmap.mark_column
      tot_val = tot_pass_marks = tot_max_marks = 0
      exam_ids.each do |exam_id|
      	#Note that we are displaying only the marks that belong to the section the student is in. We are not considering the arrear marks here.
        mark_row = Mark.search(:student_id_eq => @student.id, :semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id).result.first
        #At times, we would have associated the exams, but NOT have entered the marks. So, process the row only if 
        #a corresponding row is available.
        if mark_row && mark_row.send(mark_col) 
          mc = MarkCriteria.search(:semester_id_eq => @semester.id, :section_id_eq => @section.id, :exam_id_eq => exam_id, :subject_id_eq => ssmap.subject_id).result.first
          pass_marks = mc ? mc.pass_marks : 0
          max_marks = mc ? mc.max_marks : 0
          percentages = mark_row.percentages_with_mark_columns
          percentiles = Mark.subject_percentiles_with_mark_ids(mark_col, mark_row.section_id, mark_row.semester_id, mark_row.exam_id)  
          marks_hash[exam_id.to_s] =  { 	
          															:value => mark_row.send(mark_col), :bg => Grade.get_color_code(mark_row.send(mark_col)) , 
          															:max_marks => max_marks,  :pass_marks => pass_marks, 
          															:percentage => percentages[mark_col], :percentile => percentiles[mark_row.id]
    	  														}
    	  #Add the value in each iteration to get the sum of the marks of exam and assignments.
          tot_val = tot_val + mark_row.send(mark_col)    															
          tot_pass_marks = tot_pass_marks + pass_marks
          tot_max_marks = tot_max_marks + max_marks
        end
      end
      tot_percentage = tot_val.to_f * 100 / tot_max_marks
      marks_hash['total_marks'] = tot_val
      marks_hash['percentage'] = tot_percentage
      sub_type = ssmap.subject.lab ? " (Pr) " : " (Th) "
      table_values << {:subject_name =>  ssmap.subject.name + sub_type}.merge(marks_hash)
    end
    return {:column_keys => column_keys, :column_headings => column_headings, :table_values => table_values}
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
              																		:value => mark_row.send(sub_map.mark_column), :bg => Grade.get_color_code(mark_row.send(sub_map.mark_column)) , 
              																		:percentage => percentages[sub_map.mark_column], :percentile => percentiles[mark_row.id],
            																		:subject_name =>  sub_map.subject.name + sub_type
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
    return {:table_values => table_values}
  end


end
