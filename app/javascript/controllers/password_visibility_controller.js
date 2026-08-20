import { Controller } from "@hotwired/stimulus"

// Alterna um campo de senha entre oculto (••••) e visível (texto), com o
// ícone de olho trocando de acordo. Reutilizável em qualquer formulário:
// basta envolver o input com data-controller="password-visibility".
export default class extends Controller {
    static targets = ["input", "icon"]

    toggle() {
    const estaOculta = this.inputTarget.type === "password"
    this.inputTarget.type = estaOculta ? "text" : "password"
    this.iconTarget.setAttribute("data-lucide", estaOculta ? "eye-off" : "eye")

    if (window.lucide) {
        window.lucide.createIcons()
        }
    }
}
