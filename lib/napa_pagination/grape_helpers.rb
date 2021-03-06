module NapaPagination
  module GrapeHelpers
    def paginate(data, with: nil, **args)
      raise ArgumentError.new(":with option is required") if with.nil?

      if data.respond_to?(:to_a)
        return {}.tap do |r|
          data = NapaPagination::Pagination.new(represent_pagination(data))
          r[:data] = data.map{ |item| with.new(item).to_hash(args) }
          r[:pagination] = data.to_h
        end
      else
        return { data: with.new(data).to_hash(args) }
      end
    end

    def represent_pagination(data)
      # don't paginate if collection is already paginated
      return data if data.respond_to?(:total_count)

      page      = params.try(:page) || 1
      per_page  = params.try(:per_page) || 25

      order_by_params!(data) if data.is_a?(ActiveRecord::Relation) && data.size > 0 

      if data.is_a?(Array)
        Kaminari.paginate_array(data).page(page).per(per_page)
      else
        data.page(page).per(per_page)
      end
    end

    def order_by_params!(data)
      if data.column_names.map(&:to_sym).include?(params[:sort_by])
        sort_order = params.try(:sort_order) || :asc
        data.order!(params[:sort_by] => sort_order)
      end
      data
    end

    # extend all endpoints to include this
    Grape::Endpoint.send :include, self
  end
end
