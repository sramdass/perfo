class ReportsController < ApplicationController
  def index
    @batches = Batch.all
    @departments = Department.all
    @semesters = Semester.all
  end

end
