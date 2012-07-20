#Place all the global constants for perfo here

#Number of  subject columns in the marks table. This should not be greater than 20. There are only 20 fields
#in the marks table. If this has to be changed to a higher value, the fileds in the marks table has to be
#increased accordingly.
MARKS_SUBJECTS_COUNT=20

#default max_marks criteria (used in MarkCriteria table)
DEFAULT_MAX_MARKS = 100

#default pass marks criteria (used in MarkCriteria table)
DEFAULT_PASS_MARKS_PERCENTAGE = 50

#Refer mark_criteria.rb
MAX_ALLOWED_MARKS = 500
MIN_ALLOWED_MARKS = 0

#Exam Types in Exam. Refer exams.rb
EXAM_TYPE_TEST = 0
EXAM_TYPE_ASSIGNMENT = 1

#Max allowed credits for the subjects. Refer view\sections\_faculties_form.html.erb and sections_controller.rb
MAX_SUBJECT_CREDITS = 4

#Mark values that will be provided by the user in the marksheet (browser)
#Refer mark.rb
NA_MARK_CHAR = '-'
ABSENT_MARK_CHAR = 'A'
#The above two values should be changed to these two values when stored in the database.
NA_MARK_NUM = -1267
ABSENT_MARK_NUM = -2398


