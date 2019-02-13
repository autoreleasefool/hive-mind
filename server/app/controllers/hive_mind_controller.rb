class HiveMindController < ApplicationController

  def new
    state = `#{hiveMindExecutable} --new`
    render(json: state, status: :ok)
  end

  def play
    move = `#{hiveMindExecutable} --play #{params[:state]}`
    render(json: state, status: :ok)
  end

  def available_moves
    moves = `#{hiveMindExecutable} --moves '#{params[:state]}'`
    render(json: moves, status: :ok)
  end

  private

  def hiveMindExecutable
    return Rails.root.join('..', 'hivemind', '.build', 'debug', 'hivemind').to_s
  end

end