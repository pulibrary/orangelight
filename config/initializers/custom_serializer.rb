# frozen_string_literal: true

require './app/serializers/submission_serializer'

Rails.application.config.active_job.custom_serializers.push(SubmissionSerializer)
