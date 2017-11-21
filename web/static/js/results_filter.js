/*
* Toggle for evidence type filter menu
*/
module.exports = (function() {
  document.getElementById('filter-evidence').addEventListener('click', filterEvidence);

  function filterEvidence () {
    var evidenceType = document.getElementById('evidence-type');
    if (evidenceType.style.display == 'none' || evidenceType.style.display == '') {
      evidenceType.style.display = 'block';
    } else {
      evidenceType.style.display = 'none';
    }
  }
})()
