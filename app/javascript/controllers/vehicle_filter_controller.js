import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  static values = {
    totalCount: Number
  }

  connect() {
    this.initializeModels()
  }

  // Submit the form when any filter changes
  submitForm() {
    if (this.hasFormTarget) {
      this.formTarget.submit()
    }
  }

  // Handle sorting - add sort param and submit
  sort(event) {
    const sortValue = event.target.value
    const url = new URL(window.location.href)
    url.searchParams.set("sort", sortValue)
    window.location.href = url.toString()
  }

  // Update model options based on selected brand
  updateModels(event) {
    const brand = event.target.value
    const modelSelect = this.element.querySelector("#modell")
    if (!modelSelect) return

    const modelsByBrand = {
      "BMW": ["X3", "3er", "5er", "X5", "1er", "X1"],
      "Audi": ["A1", "A3", "A4", "A6", "Q3", "Q5"],
      "Mercedes-Benz": ["A-Klasse", "C-Klasse", "E-Klasse", "GLC", "GLE"],
      "Volkswagen": ["Golf", "Passat", "Tiguan", "Polo", "T-Roc"],
      "Porsche": ["Cayenne", "Macan", "911", "Taycan"],
      "Renault": ["Twingo", "Clio", "Captur", "Megane"],
      "Skoda": ["Fabia", "Octavia", "Superb", "Kodiaq"],
      "Tesla": ["Model 3", "Model Y", "Model S", "Model X"]
    }

    // Clear current options
    modelSelect.innerHTML = '<option value="" class="bg-gray-900 text-white">Alle Modelle</option>'

    // Add models for selected brand
    if (brand && modelsByBrand[brand]) {
      modelsByBrand[brand].forEach(model => {
        const option = document.createElement("option")
        option.value = model
        option.textContent = model
        option.className = "bg-gray-900 text-white"
        modelSelect.appendChild(option)
      })
    }
  }

  // Initialize model dropdown based on current brand selection
  initializeModels() {
    const brandSelect = this.element.querySelector("#marke")
    const modelSelect = this.element.querySelector("#modell")

    if (brandSelect && modelSelect && brandSelect.value) {
      // Get current model from URL params
      const urlParams = new URLSearchParams(window.location.search)
      const currentModel = urlParams.get("modell")

      // Trigger updateModels to populate the dropdown
      this.updateModels({ target: brandSelect })

      // Select the current model if it exists
      if (currentModel) {
        modelSelect.value = currentModel
      }
    }
  }
}
