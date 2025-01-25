class Admin::GenerateArticlesController < ApplicationController
  def create
    Services::Articles::Generate.generate()
    generic_render(message: "Initiated Generation Service")
  end
end
