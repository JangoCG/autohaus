import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "calcomToggle"]

  static COOKIE_NAME = "consent_calcom"
  static COOKIE_DAYS = 365

  connect() {
    this.syncToggles()
    window.cookieSettings = this
  }

  disconnect() {
    if (window.cookieSettings === this) {
      window.cookieSettings = null
    }
  }

  open(event) {
    event?.preventDefault()
    this.syncToggles()
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  syncToggles() {
    if (this.hasCalcomToggleTarget) {
      this.calcomToggleTarget.checked = this.getCookie(this.constructor.COOKIE_NAME) === "accepted"
    }
  }

  save() {
    if (this.hasCalcomToggleTarget) {
      if (this.calcomToggleTarget.checked) {
        this.setCookie(this.constructor.COOKIE_NAME, "accepted", this.constructor.COOKIE_DAYS)
      } else {
        this.deleteCookie(this.constructor.COOKIE_NAME)
      }
    }
    this.close()
    window.location.reload()
  }

  acceptAll() {
    this.setCookie(this.constructor.COOKIE_NAME, "accepted", this.constructor.COOKIE_DAYS)
    this.close()
    window.location.reload()
  }

  setCookie(name, value, days) {
    const expires = new Date(Date.now() + days * 864e5).toUTCString()
    document.cookie = `${name}=${encodeURIComponent(value)}; expires=${expires}; path=/; SameSite=Lax`
  }

  getCookie(name) {
    const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'))
    return match ? decodeURIComponent(match[2]) : null
  }

  deleteCookie(name) {
    document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; SameSite=Lax`
  }
}
