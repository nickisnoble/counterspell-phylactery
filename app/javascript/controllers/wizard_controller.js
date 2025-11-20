import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="wizard"
export default class extends Controller {
  static targets = ["step", "nextButton", "prevButton", "submitButton", "heroOption", "selectedRole"]
  static values = {
    currentStep: { type: Number, default: 0 }
  }

  connect() {
    this.showCurrentStep()
  }

  roleSelected(event) {
    const selectedRole = event.target.value

    // Filter heroes by selected role
    this.heroOptionTargets.forEach(heroLabel => {
      const heroRole = heroLabel.dataset.heroRole
      const heroRadio = heroLabel.querySelector('input[type="radio"]')

      if (heroRole === selectedRole) {
        heroLabel.classList.remove("hidden")
        if (heroRadio && heroRadio.disabled) {
          // Keep disabled heroes visible but grayed out
        } else if (heroRadio) {
          heroRadio.required = true
        }
      } else {
        heroLabel.classList.add("hidden")
        if (heroRadio) {
          heroRadio.required = false
          heroRadio.checked = false
        }
      }
    })

    // Update the selected role text in step 2
    if (this.hasSelectedRoleTarget) {
      this.selectedRoleTarget.textContent = `Role: ${selectedRole.charAt(0).toUpperCase() + selectedRole.slice(1)}`
    }
  }

  next(event) {
    event.preventDefault()

    // Validate current step before proceeding
    if (!this.validateCurrentStep()) {
      return
    }

    if (this.currentStepValue < this.stepTargets.length - 1) {
      this.currentStepValue++
      this.showCurrentStep()
      this.updateReviewStep()
    }
  }

  previous(event) {
    event.preventDefault()

    if (this.currentStepValue > 0) {
      this.currentStepValue--
      this.showCurrentStep()
    }
  }

  showCurrentStep() {
    this.stepTargets.forEach((step, index) => {
      if (index === this.currentStepValue) {
        step.classList.remove("hidden")
      } else {
        step.classList.add("hidden")
      }
    })

    this.updateButtons()
  }

  updateButtons() {
    const isFirstStep = this.currentStepValue === 0
    const isLastStep = this.currentStepValue === this.stepTargets.length - 1

    // Show/hide previous button
    if (this.hasPrevButtonTarget) {
      if (isFirstStep) {
        this.prevButtonTarget.classList.add("hidden")
      } else {
        this.prevButtonTarget.classList.remove("hidden")
      }
    }

    // Show/hide next button
    if (this.hasNextButtonTarget) {
      if (isLastStep) {
        this.nextButtonTarget.classList.add("hidden")
      } else {
        this.nextButtonTarget.classList.remove("hidden")
      }
    }

    // Show/hide submit button
    if (this.hasSubmitButtonTarget) {
      if (isLastStep) {
        this.submitButtonTarget.classList.remove("hidden")
      } else {
        this.submitButtonTarget.classList.add("hidden")
      }
    }
  }

  updateReviewStep() {
    // Update the review step with selected hero information
    const selectedHeroRadio = this.element.querySelector('input[name="hero_id"]:checked')
    if (selectedHeroRadio) {
      const heroLabel = selectedHeroRadio.closest('label')
      const heroName = heroLabel.querySelector('.font-semibold')?.textContent || 'Unknown Hero'

      const heroNameDisplay = this.element.querySelector('[data-hero-name="hero-name-display"]')
      if (heroNameDisplay) {
        heroNameDisplay.textContent = heroName
      }
    }
  }

  validateCurrentStep() {
    const currentStep = this.stepTargets[this.currentStepValue]

    // Check for required radio buttons in the current step
    const radioGroups = new Set()
    const radios = currentStep.querySelectorAll('input[type="radio"][required]')

    radios.forEach(radio => {
      radioGroups.add(radio.name)
    })

    // Validate each radio group has a selection
    for (const groupName of radioGroups) {
      const selectedRadio = currentStep.querySelector(`input[name="${groupName}"]:checked`)
      if (!selectedRadio) {
        // Highlight the error or show a message
        alert("Please select an option before continuing")
        return false
      }
    }

    // Check for other required fields
    const requiredInputs = currentStep.querySelectorAll('input[required]:not([type="radio"]), select[required], textarea[required]')
    for (const input of requiredInputs) {
      if (!input.value || input.value.trim() === '') {
        alert("Please fill in all required fields")
        return false
      }
    }

    return true
  }
}
