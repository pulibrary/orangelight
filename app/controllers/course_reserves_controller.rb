class CourseReservesController < ApplicationController
  def index
    @courses = CourseReserveRepository.all
  end
end
