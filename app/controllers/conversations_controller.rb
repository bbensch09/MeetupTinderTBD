# matched_user_id\"=>\"2\", \"author\"=>\"31\", \"text\"=>\"test!\", \"controller\"=>\"conversations\", \"action\"=>\"create\", \"id\"=>\"3\"}"

include MatchesHelper

class ConversationsController < ApplicationController
  def create
    Message.create(match_id: params[:id], message_text: params[:text], user_id: params[:author], sender_name: User.find(params[:author]).first_name)
    p "+++++++++++++++++"
    p presenter = generate_presenter( {match_id: params[:id], sender_id: params[:author]} )
    p "+++++++++++++++++"
    render :json => presenter
  end

  def show
    # get the matched user's info
    @match = Match.find(params[:id])
    @matched_user = get_matched_user(@match, current_user)
    @presenter = generate_presenter( {match_id: @match.id, sender_id: current_user.id} )
    if request.xhr?
      render :json => generate_presenter( {match_id: @match.id, sender_id: current_user.id} )
    end
  end

  private

  def generate_presenter(options)
    match = Match.find( options.fetch(:match_id) )
    sender = User.find( options.fetch(:sender_id) )
    matched_user = get_matched_user(match, sender)
    return {
          :messages => Message.where(match_id: match.id).order('created_at ASC'),
          :form => {
            :action => "/matches/#{match.id}/chat",
            :csrf_param => request_forgery_protection_token,
            :csrf_token => form_authenticity_token,
            :sender_id => sender.id,
            :matched_user_id => matched_user.id
          }
        }
  end
end