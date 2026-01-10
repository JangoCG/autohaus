class Vehicle < ApplicationRecord
  # Scopes for filtering
  scope :by_brand, ->(brand) { where(brand: brand) if brand.present? }
  scope :by_model, ->(model) { where("vehicle_model LIKE ?", "%#{model}%") if model.present? }
  scope :by_max_price, ->(price) { where("price <= ?", price) if price.present? }
  scope :by_min_year, ->(year) { where("year >= ?", year) if year.present? }
  scope :by_fuel_type, ->(fuel) { where(fuel_type: fuel) if fuel.present? }
  scope :by_transmission, ->(trans) { where(transmission: trans) if trans.present? }
  scope :by_max_mileage, ->(mileage) { where("mileage <= ?", mileage) if mileage.present? }
  scope :by_min_horsepower, ->(hp) { where("horsepower >= ?", hp) if hp.present? }

  # Combined filter scope using German param names from frontend
  def self.filter_by(params)
    all
      .by_brand(params[:marke])
      .by_model(params[:modell])
      .by_max_price(params[:preis])
      .by_min_year(params[:erstzulassung])
      .by_fuel_type(params[:kraftstoff])
      .by_transmission(params[:getriebe])
      .by_max_mileage(params[:km_bis])
      .by_min_horsepower(params[:leistung])
  end

  # Sorting
  def self.sorted_by(sort_param)
    case sort_param
    when "price-asc"
      order(price: :asc)
    when "price-desc"
      order(price: :desc)
    when "km-asc"
      order(mileage: :asc)
    when "year-desc"
      order(year: :desc)
    else
      order(created_at: :desc)
    end
  end

  # Display helpers
  def full_name
    "#{brand} #{vehicle_model}"
  end

  def formatted_price
    "#{price.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse},- EUR"
  end

  def formatted_mileage
    "#{mileage.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse} km"
  end

  def formatted_power
    "#{kilowatts} kW (#{horsepower} PS)"
  end

  def formatted_monthly_rate
    "ab #{monthly_rate} EUR/mtl."
  end

  def badge
    if year >= Date.current.year
      "NEUWAGEN"
    elsif year >= Date.current.year - 1
      "JAHRESWAGEN"
    else
      "GEBRAUCHTWAGEN"
    end
  end

  def badge_color
    case badge
    when "NEUWAGEN" then "sky-500"
    when "JAHRESWAGEN" then "emerald-500"
    else "gray-900"
    end
  end
end
