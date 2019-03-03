class HiveMindController < ApplicationController

  def new
    render(json: "{}", status: :ok)
  end

  def play
    move = `#{hiveMindExecutable} --play '#{request.body.read()}'`
    render(json: move, status: :ok)
  end

  private

  def hiveMindExecutable
    return Rails.root.join('..', 'hivemind', '.build', 'debug', 'HiveMind').to_s
  end

end