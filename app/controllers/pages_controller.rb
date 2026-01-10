class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @featured_vehicles = Vehicle.order(created_at: :desc).limit(8)
  end

  def impressum
  end

  def datenschutz
  end

  def fahrzeuge
    @vehicles = Vehicle.filter_by(filter_params).sorted_by(params[:sort])
    @total_count = Vehicle.count

    # Get unique values for filter dropdowns
    @brands = Vehicle.distinct.pluck(:brand).sort
    @fuel_types = Vehicle.distinct.pluck(:fuel_type).sort
    @transmissions = Vehicle.distinct.pluck(:transmission).sort
  end

  private

  def filter_params
    params.permit(:marke, :modell, :preis, :erstzulassung, :kraftstoff, :getriebe, :km_bis, :leistung)
  end
end
