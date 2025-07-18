# app/views/reports/print.json.jbuilder

json.period @period.strftime("%Y-%m")

json.orders do
  json.total     @orders_count
  json.resin     @resin_count
  json.fdm       @fdm_count
  json.multiple  @multiple_count
  json.cancelled @cancelled_count
end

json.individuals       @distinct_patrons
json.total_prints      @total_quantity
json.unique_designs    @unique_designs

json.filament_used do
  json.grams @filament_grams
end

json.resin_used do
  json.ml @resin_ml
end

json.by_category @category_counts
