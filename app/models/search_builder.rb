# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]

  def where conditions
    if conditions[:id].present?
      if conditions[:id].is_a? Array
        conditions[:id].map!{|s| URI.decode(s)}
      end
      if conditions[:id].is_a? String
        conditions[:id] = URI.decode(conditions[:id])
      end
    end
    super conditions
  end
end
