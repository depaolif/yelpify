class SongsController < ApplicationController
  helper_method :my_review_for_song

  def create
  end

  def trending_songs
    @ordered_songs_array = Song.trending
    render :trending
  end

  def show
    @song = Song.find_by(id: params[:id])
    @song.reviews.each do |review|
      if logged_in? && !current_user.voted?(review.id)
        Vote.create(score: 0, review_id: review.id, account_id: current_user.id)
      end
    end
    @review = Review.new
  end


  def vote
    vote = Vote.new(score: vote_attributes[:vote], review_id: vote_attributes[:review_id].to_i)
    vote.account_id = current_user.id
    prev = 0
    vote.save
    redirect_to song_path(params[:song_id])
  end

  def change_vote
    vote = Vote.where(account_id: current_user.id, review_id: params[:review_id]).first
    prev = vote.score
    vote.update(score: vote_attributes[:vote])
    if vote.save
      ActionCable.server.broadcast 'upvotes',
        score: vote.score,
        review_id: vote.review_id,
        prev: prev,
        account_id: current_user.id
      head :ok
      @review = Review.find_by(id: vote.review_id)
      @review.calculate_weighted_score
    end
    # redirect_to song_path(params[:song_id])
  end

  private
  def vote_attributes
    params.permit(:vote, :review_id, :account_id)
  end

  def my_review_for_song(song, current_user)
    song.reviews.find {|review| review.account_id == current_user.id}
  end

end
