# frozen_string_literal: true
class SubmissionSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(submission)
    super(
      'patron' => {
        'user' => {
          'uid' => submission.patron.user.uid,
          'username' => submission.patron.user.username,
          'guest' => submission.patron.user.guest,
          'provider' => submission.patron.user.provider
        },
        'patron_hash' => submission.patron.to_h
      },
      'items' => [],
      'bib' => {
        'id' => ''
      },
      'services' => [],
      'success_messages' => []
    )
  end

  def deserialize(hash)
    user_hash = hash.dig('patron', 'user')
    user = User.new(user_hash['uid'], user_hash['username'], user_hash['guest'], user_hash['provider'])
    Requests::Patron.authorize(user:)
    Requests::Submission.new(hash['params'], hash['patron'])
  end

  private

    def klass
      Requests::Submission
    end
end
