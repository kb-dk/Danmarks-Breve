# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  def build_all_brevudgivelser_search solr_params = {}
    solr_params[:fq] = []
    solr_params[:fq] << 'cat_ssi:letterbook'
    solr_params[:sort] = []
    solr_params[:sort] << 'publisher_name_ssi asc'
    solr_params[:rows] = 10000
  end
end