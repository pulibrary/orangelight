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
        'patron_hash' => submission.patron.patron_hash
      },
      'items' => submission.items,
      'bib' => submission.bib,
      'services' => [],
      'success_messages' => []
    )
  end

  def deserialize(hash)
    user_hash = hash.dig('patron', 'user')
    user = User.from_hash(user_hash)
    params = {
      requestable: hash['items'],
      bib: hash['bib']
    }
    patron = Requests::Patron.new(user: user, patron_hash: hash.dig('patron', 'patron_hash'))
    Requests::Submission.new(params, patron)
  end

  private

    def klass
      Requests::Submission
    end
end
