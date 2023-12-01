document.addEventListener('DOMContentLoaded', () => {
    const buttonAdd = document.getElementById('add');
    const progress = document.getElementById('popo');

    buttonAdd.addEventListener('click', () => {
        progress.style.width = '70%';
    })
});