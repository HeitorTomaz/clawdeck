module FiltersHelper
  # Active count: # de filtros aplicados (nao-vazios)
  def filters_active_count(params)
    %i[q tag touched_by column].count { |k| Array(params[k]).reject(&:blank?).any? }
  end

  def filter_path_without(base_path, params, key, value)
    new_params = params.permit(q: [], tag: [], touched_by: [], column: []).to_h
    new_params[key] = Array(new_params[key]) - [ value ]
    "#{base_path}?#{new_params.compact_blank.to_query}"
  end
end
