# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # Main landing page - could redirect to app or show welcome page
    if user_signed_in?
      redirect_to '/app'
    else
      render 'welcome'
    end
  end

  def app
    # Serve the Vue.js SPA
    render 'app', layout: 'application'
  end
end
