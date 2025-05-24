module Solidstats
  class GemMetadataController < ApplicationController
    def index
      @gems = Solidstats::GemMetadata::FetcherService.call
      
      respond_to do |format|
        format.html
        format.json { render json: { gems: @gems } }
      end
    end
    
    def refresh
      @gems = Solidstats::GemMetadata::FetcherService.call(nil, true)
      
      respond_to do |format|
        format.html { redirect_to solidstats_gem_metadata_index_path, notice: "Gem metadata refreshed successfully." }
        format.json { render json: { gems: @gems } }
      end
    end
  end
end
