# frozen_string_literal: true

# This class serializes and deserializes the Submission
# object so it can be used in ActiveJob queues
class SubmissionSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(submission)
    patron = submission.patron
    user = patron.user
    super(
      'patron' => {
        'user' => {
          'uid' => user.uid,
          'username' => user.username,
          'guest' => user.guest,
          'provider' => user.provider
        },
        'patron_hash' => patron.patron_hash
      },
      'items' => submission.items,
      'bib' => submission.bib,
      'services' => [],
      'success_messages' => []
    )
  end

  # This method is required to implement the ActiveJob::Serializer::ObjectSerializer
  # :reek:UtilityFunction
  def deserialize(hash)
    user_hash = hash.dig('patron', 'user')
    user = User.from_hash(user_hash)
    params = {
      requestable: hash['items'],
      bib: hash['bib']
    }
    patron = Requests::Patron.new(user:, patron_hash: hash.dig('patron', 'patron_hash'))
    Requests::Submission.new(params, patron)
  end

  private

    def klass
      Requests::Submission
    end
end
