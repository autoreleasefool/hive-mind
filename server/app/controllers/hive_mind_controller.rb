class HiveMindController < ApplicationController

  def new
    state = `#{hiveMindExecutable} --new`
    render(json: state, status: :ok)
  end

  def play
    move = `#{hiveMindExecutable} --play '#{request.body.json()}'`
    render(json: move, status: :ok)
  end

  def available_moves
    moves = `#{hiveMindExecutable} --moves '#{request.body.json()}'`
    render(json: moves, status: :ok)
  end

  private

  def hiveMindExecutable
    return Rails.root.join('..', 'hivemind', '.build', 'debug', 'HiveMind').to_s
  end

end