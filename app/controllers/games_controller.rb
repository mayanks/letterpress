class GamesController < ApplicationController
  # GET /games
  # GET /games.json
  def index
    if current_user
      @games = Game.all(:conditions => ["player_a_id = ? or player_b_id = ?",current_user.id, current_user.id], :order => "id desc")
    else
      @game = Game.last
      render :action => "show"
    end

  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])

    respond_to do |format|
      flash[:notice] = "Your opponent played <b>#{@game.words.last}</b>.#{@game.status_string(current_user)}" if params[:showMsg]
      format.html # show.html.erb
      format.json { render text: @game.to_json(:only => [:state]) }
    end
  end

  # GET /games/new
  # GET /games/new.json
  def new
    if current_user
      @game = Game.first(:conditions => ["state = ? and player_a_id != ? ", Game::STATE_WAITING, current_user.id])
      if @game
        @game.update_attributes(:state => Game::STATE_P2_WAITING, :player_b_id => current_user.id)
      else
        @game = Game.first(:conditions => ["state = ? and player_a_id = ?", Game::STATE_NEW, current_user.id])
        @game = Game.create(:player_a_id => current_user.id) unless @game
      end
      redirect_to game_path(@game)
    else
      redirect_to root_path
    end
  end

  # PUT /games/1
  # PUT /games/1.json
  def update
    @game = Game.find(params[:id])
    sequence = params[:sequence].split(",").map{|a|a.to_i}

    respond_to do |format|
      if @game.play(sequence,current_user)
        msg = "You played <b>#{@game.words.last}</b>. #{@game.status_string(current_user)}"
        format.html { redirect_to @game, notice: msg }
        format.json { head :no_content }
        format.js {render :partial => "show"}
      else
        format.html { redirect_to @game, notice: @game.error }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end
end
