import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  connect() {
    this.initializeAbilities()
  }

  initializeAbilities() {
    const hiddenInput = this.element.querySelector('input[type="hidden"]')
    if (hiddenInput && hiddenInput.value) {
      try {
        const abilities = JSON.parse(hiddenInput.value)
        Object.entries(abilities).forEach(([key, value]) => {
          this.addAbilityRow(key, value)
        })
      } catch (e) {
        // If parsing fails, start with empty abilities
        this.addAbilityRow()
      }
    } else {
      // Start with one empty row
      this.addAbilityRow()
    }
  }

  addAbility(event) {
    event.preventDefault()
    this.addAbilityRow()
  }

  addAbilityRow(key = "", value = "") {
    const template = this.templateTarget.content.cloneNode(true)
    const keyInput = template.querySelector('.ability-key')
    const valueInput = template.querySelector('.ability-value')
    
    keyInput.value = key
    valueInput.value = value
    
    this.containerTarget.appendChild(template)
    this.updateHiddenInput()
  }

  removeAbility(event) {
    event.preventDefault()
    const row = event.target.closest('.ability-row')
    const keyInput = row.querySelector('.ability-key')
    const valueInput = row.querySelector('.ability-value')
    
    const hasContent = keyInput.value.trim() || valueInput.value.trim()
    
    if (hasContent && !confirm('This ability has content. Are you sure you want to remove it?')) {
      return
    }
    
    row.remove()
    this.updateHiddenInput()
    
    // Ensure at least one row exists
    if (this.containerTarget.children.length === 0) {
      this.addAbilityRow()
    }
  }

  updateAbilities() {
    this.updateHiddenInput()
  }

  updateHiddenInput() {
    const rows = this.containerTarget.querySelectorAll('.ability-row')
    const abilities = {}
    
    rows.forEach(row => {
      const key = row.querySelector('.ability-key').value.trim()
      const value = row.querySelector('.ability-value').value.trim()
      
      if (key && value) {
        abilities[key] = value
      }
    })
    
    const hiddenInput = this.element.querySelector('input[type="hidden"]')
    hiddenInput.value = JSON.stringify(abilities)
  }
}