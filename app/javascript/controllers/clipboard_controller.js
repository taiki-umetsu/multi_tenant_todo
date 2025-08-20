import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }
  static targets = ["button"]

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => {
      // コピー成功時の視覚的フィードバック
      this.buttonTarget.textContent = "コピーしました"

    }).catch(err => {
      console.error('クリップボードへのコピーに失敗しました:', err)
      alert('コピーに失敗しました')
    })
  }
}
