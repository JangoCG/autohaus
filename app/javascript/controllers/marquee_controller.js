import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track"]
  static values = {
    speed: { type: Number, default: 1 },
    pauseOnHover: { type: Boolean, default: true }
  }

  connect() {
    this.position = 0
    this.isPaused = false
    this.duplicateContent()
    this.animate()

    if (this.pauseOnHoverValue) {
      this.element.addEventListener("mouseenter", () => this.pause())
      this.element.addEventListener("mouseleave", () => this.resume())
    }
  }

  disconnect() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
    }
  }

  duplicateContent() {
    // Clone the track content for seamless infinite scroll
    const track = this.trackTarget
    const content = track.innerHTML
    track.innerHTML = content + content
  }

  animate() {
    if (!this.isPaused) {
      this.position -= this.speedValue

      // Reset position when first set of cards is fully scrolled
      const track = this.trackTarget
      const halfWidth = track.scrollWidth / 2

      if (Math.abs(this.position) >= halfWidth) {
        this.position = 0
      }

      track.style.transform = `translateX(${this.position}px)`
    }

    this.animationId = requestAnimationFrame(() => this.animate())
  }

  pause() {
    this.isPaused = true
  }

  resume() {
    this.isPaused = false
  }
}
