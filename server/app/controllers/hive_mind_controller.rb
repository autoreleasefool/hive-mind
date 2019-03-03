class HiveMindController < ApplicationController

  def new
    if params['playerIsFirst'] then
      render(json: "{}", status: :ok)
    else
      state = `#{hiveMindExecutable} --new`
      move = `#{hiveMindExecutable} --play '#{state}'`
      render(json: move, status: :ok)
    end
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