# frozen_string_literal: true

class CourseReservesController < ApplicationController
  def index
    @courses = CourseReserveRepository.all
  end
end
