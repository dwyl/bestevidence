const createMsgBtn = document.getElementById('create-msg-btn')
const msgDiv = document.getElementById('msg-div')
const hideMsgDivBtn = document.getElementById('hide-msg-div-btn')

createMsgBtn.addEventListener('click', function () {
  msgDiv.classList.remove('dn')
})

hideMsgDivBtn.addEventListener('click', function () {
  msgDiv.classList.add('dn')
})
