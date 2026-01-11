import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "content", "calcomFrame"]
  static values = {
    calcomSrc: String
  }

  static COOKIE_NAME = "consent_calcom"
  static COOKIE_DAYS = 365

  connect() {
    this.checkConsent()
  }

  checkConsent() {
    if (this.getCookie(this.constructor.COOKIE_NAME) === "accepted") {
      this.hideOverlay()
      this.loadCalcom()
    } else {
      this.showOverlay()
    }
  }

  accept() {
    this.setCookie(this.constructor.COOKIE_NAME, "accepted", this.constructor.COOKIE_DAYS)
    this.hideOverlay()
    this.loadCalcom()
  }

  showOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("hidden")
    }
    if (this.hasContentTarget) {
      this.contentTarget.classList.add("blur-sm", "pointer-events-none")
    }
  }

  hideOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("hidden")
    }
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("blur-sm", "pointer-events-none")
    }
  }

  loadCalcom() {
    if (this.hasCalcomFrameTarget && this.hasCalcomSrcValue) {
      this.calcomFrameTarget.src = this.calcomSrcValue
    }
  }

  setCookie(name, value, days) {
    const expires = new Date(Date.now() + days * 864e5).toUTCString()
    document.cookie = `${name}=${encodeURIComponent(value)}; expires=${expires}; path=/; SameSite=Lax`
  }

  getCookie(name) {
    const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'))
    return match ? decodeURIComponent(match[2]) : null
  }
}
