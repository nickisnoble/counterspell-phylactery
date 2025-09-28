import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  connect() {
    this.initializeAbilities()
  }

  initializeAbilities() {
    // Look for existing abilities data from data attribute or server
    const abilities = this.getExistingAbilities()
    
    if (abilities && Object.keys(abilities).length > 0) {
      Object.entries(abilities).forEach(([key, value]) => {
        this.addAbilityRow(key, value)
      })
    } else {
      // Start with one empty row
      this.addAbilityRow()
    }
  }

  getExistingAbilities() {
    // Try to extract abilities from data attribute
    const abilitiesData = this.element.dataset.abilities
    if (abilitiesData) {
      try {
        return JSON.parse(abilitiesData)
      } catch (e) {
        console.warn('Failed to parse abilities data:', e)
      }
    }
    return {}
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
    
    // Add event listeners to update the input names when the key changes
    keyInput.addEventListener('input', () => this.updateInputNames(keyInput, valueInput))
    
    this.containerTarget.appendChild(template)
    this.updateInputNames(keyInput, valueInput)
  }

  updateInputNames(keyInput, valueInput) {
    const abilityName = keyInput.value.trim()
    if (abilityName) {
      // Use the ability name as the Rails parameter key
      valueInput.name = `trait[abilities][${abilityName}]`
    } else {
      // Clear the name if no ability name is set
      valueInput.name = ""
    }
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
    
    // Ensure at least one row exists
    if (this.containerTarget.children.length === 0) {
      this.addAbilityRow()
    }
  }
}