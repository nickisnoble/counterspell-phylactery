import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["traitSection", "traitSelection", "selectedTrait", "traitSelect", "newTraitForm", "newTraitType", "newTraitName", "newTraitDescription", "newTraitAbilities"]

  selectTrait(event) {
    const select = event.target
    const selectedOption = select.options[select.selectedIndex]
    
    if (selectedOption.value) {
      const traitData = JSON.parse(selectedOption.dataset.traitJson)
      const traitType = select.dataset.traitType
      
      this.showSelectedTrait(traitData, traitType, select)
    }
  }

  showSelectedTrait(traitData, traitType, selectElement) {
    const traitSection = selectElement.closest('[data-hero-traits-target="traitSection"]')
    const traitSelection = traitSection.querySelector('[data-hero-traits-target="traitSelection"]')
    
    // Create the selected trait display
    const selectedTraitHtml = `
      <div class="selected-trait bg-gray-50 p-4 rounded-md border" data-hero-traits-target="selectedTrait">
        <div class="w-full sm:w-auto my-5 space-y-5">
          <div>
            <strong class="block font-medium mb-1">Type:</strong>
            ${traitData.type}
          </div>
          <div>
            <strong class="block font-medium mb-1">Name:</strong>
            ${traitData.name}
          </div>
          <div>
            <strong class="block font-medium mb-1">Slug:</strong>
            ${traitData.slug}
          </div>
          <div>
            <strong class="block font-medium mb-1">Abilities:</strong>
            ${this.formatAbilities(traitData.abilities)}
          </div>
        </div>
        <div class="mt-3">
          <button type="button" 
                  class="px-3 py-2 text-sm bg-red-100 hover:bg-red-200 text-red-700 border border-red-300 rounded-md"
                  data-action="click->hero-traits#removeTrait"
                  data-trait-type="${traitType}">
            Remove
          </button>
        </div>
        <input type="hidden" name="trait_ids_${traitType}" value="${traitData.id}">
      </div>
    `
    
    // Replace the selection interface with the selected trait
    traitSelection.innerHTML = selectedTraitHtml
  }

  removeTrait(event) {
    event.preventDefault()
    const traitType = event.target.dataset.traitType
    const traitSection = event.target.closest('[data-hero-traits-target="traitSection"]')
    
    // Restore the selection interface
    this.restoreTraitSelection(traitSection, traitType)
  }

  showNewTraitForm(event) {
    event.preventDefault()
    const traitType = event.target.dataset.traitType
    const traitSection = event.target.closest('[data-hero-traits-target="traitSection"]')
    const newTraitForm = traitSection.querySelector('[data-hero-traits-target="newTraitForm"]')
    
    newTraitForm.classList.remove('hidden')
    
    // Set the trait type
    const typeInput = newTraitForm.querySelector('[data-hero-traits-target="newTraitType"]')
    typeInput.value = traitType
    
    // Clear other fields
    const nameInput = newTraitForm.querySelector('[data-hero-traits-target="newTraitName"]')
    const descInput = newTraitForm.querySelector('[data-hero-traits-target="newTraitDescription"]')
    const abilitiesInput = newTraitForm.querySelector('[data-hero-traits-target="newTraitAbilities"]')
    nameInput.value = ''
    descInput.value = ''
    abilitiesInput.value = '{}'
    
    nameInput.focus()
  }

  hideNewTraitForm(event) {
    event.preventDefault()
    const newTraitForm = event.target.closest('[data-hero-traits-target="newTraitForm"]')
    newTraitForm.classList.add('hidden')
  }

  async createAndSelectTrait(event) {
    event.preventDefault()
    const newTraitForm = event.target.closest('[data-hero-traits-target="newTraitForm"]')
    const typeInput = newTraitForm.querySelector('[data-hero-traits-target="newTraitType"]')
    const nameInput = newTraitForm.querySelector('[data-hero-traits-target="newTraitName"]')
    const descInput = newTraitForm.querySelector('[data-hero-traits-target="newTraitDescription"]')
    const abilitiesInput = newTraitForm.querySelector('[data-hero-traits-target="newTraitAbilities"]')
    
    if (!nameInput.value.trim()) {
      this.showNotification('Name is required', 'error')
      nameInput.focus()
      return
    }
    
    const formData = new FormData()
    formData.append('trait[type]', typeInput.value)
    formData.append('trait[name]', nameInput.value.trim())
    formData.append('trait[description]', descInput.value.trim())
    formData.append('trait[abilities]', abilitiesInput.value)
    
    try {
      const response = await fetch('/traits', {
        method: 'POST',
        body: formData,
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })
      
      const data = await response.json()
      
      if (data.success) {
        // Show the newly created trait as selected
        const traitType = typeInput.value.toLowerCase()
        this.showSelectedTrait(data.trait, traitType, newTraitForm)
        
        // Hide the form
        newTraitForm.classList.add('hidden')
        
        this.showNotification('Trait created and selected!', 'success')
      } else {
        this.showNotification(data.errors ? data.errors.join(', ') : 'Error creating trait', 'error')
      }
    } catch (error) {
      this.showNotification('Error creating trait. Please try again.', 'error')
    }
  }

  restoreTraitSelection(traitSection, traitType) {
    // Get the trait type data to rebuild the selection interface
    const traitTypeUpper = traitType.toUpperCase()
    
    // This is a simplified restoration - in a real app you might want to 
    // make an AJAX call to get fresh trait data
    const selectionHtml = `
      <div class="trait-selection" data-hero-traits-target="traitSelection">
        <div class="flex gap-2 mb-3">
          <select class="flex-1 shadow-sm rounded-md border border-gray-400 px-3 py-2 focus:outline-blue-600"
                  data-hero-traits-target="traitSelect"
                  data-trait-type="${traitType}"
                  data-action="change->hero-traits#selectTrait">
            <option value="">Select ${traitTypeUpper.toLowerCase().replace(/\b\w/g, l => l.toUpperCase())}...</option>
          </select>
          
          <button type="button" 
                  class="px-3 py-2 text-sm bg-green-100 hover:bg-green-200 text-green-700 border border-green-300 rounded-md"
                  data-action="click->hero-traits#showNewTraitForm"
                  data-trait-type="${traitTypeUpper}">
            + New
          </button>
        </div>
        
        <div class="new-trait-form hidden bg-blue-50 p-4 rounded-md border" data-hero-traits-target="newTraitForm">
          <h5 class="font-medium text-gray-700 mb-3">Create New ${traitTypeUpper.toLowerCase().replace(/\b\w/g, l => l.toUpperCase())}</h5>
          
          <div class="space-y-3">
            <div>
              <label class="block text-sm font-medium text-gray-700">Type</label>
              <input type="text" 
                     value="${traitTypeUpper}" 
                     readonly
                     class="mt-1 block w-full shadow-sm rounded-md border border-gray-400 px-3 py-2 bg-gray-100"
                     data-hero-traits-target="newTraitType">
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700">Name</label>
              <input type="text" 
                     class="mt-1 block w-full shadow-sm rounded-md border border-gray-400 px-3 py-2 focus:outline-blue-600"
                     data-hero-traits-target="newTraitName"
                     required>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700">Description</label>
              <textarea rows="3"
                        class="mt-1 block w-full shadow-sm rounded-md border border-gray-400 px-3 py-2 focus:outline-blue-600"
                        data-hero-traits-target="newTraitDescription"></textarea>
            </div>
            
            <div class="flex gap-2">
              <button type="button" 
                      class="px-3 py-2 text-sm bg-green-600 hover:bg-green-700 text-white rounded-md"
                      data-action="click->hero-traits#createAndSelectTrait">
                Create & Use
              </button>
              <button type="button" 
                      class="px-3 py-2 text-sm bg-gray-300 hover:bg-gray-400 text-gray-700 rounded-md"
                      data-action="click->hero-traits#hideNewTraitForm">
                Cancel
              </button>
            </div>
          </div>
        </div>
      </div>
    `
    
    traitSection.innerHTML = `
      <h4 class="text-md font-medium text-gray-700 mb-3">${traitTypeUpper.toLowerCase().replace(/\b\w/g, l => l.toUpperCase())}</h4>
      ${selectionHtml}
    `
    
    // Reload the select options via AJAX or page refresh would be better in production
    location.reload()
  }

  formatAbilities(abilities) {
    if (!abilities || Object.keys(abilities).length === 0) {
      return 'None'
    }
    
    return Object.entries(abilities)
      .map(([key, value]) => `<div class="mb-1"><strong>${key}:</strong> ${value}</div>`)
      .join('')
  }

  showNotification(message, type = 'info') {
    const notification = document.createElement('div')
    notification.className = `fixed top-4 right-4 px-4 py-2 rounded-md text-white z-50 ${
      type === 'success' ? 'bg-green-500' : 
      type === 'error' ? 'bg-red-500' : 'bg-blue-500'
    }`
    notification.textContent = message
    
    document.body.appendChild(notification)
    
    setTimeout(() => {
      notification.remove()
    }, 3000)
  }
}