module Solidstats
  class GemMetadataController < ApplicationController
    def refresh
      @gems = Solidstats::GemMetadata::FetcherService.call(nil, true)
      
      respond_to do |format|
        format.html { redirect_to '/solidstats#gem-metadata', notice: "Gem metadata refreshed successfully." }
        format.json { render json: { gems: @gems } }
      end
    end
  end
end
