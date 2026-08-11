document.addEventListener('DOMContentLoaded', () => {
  console.log('🐾 Paws & Homes Rails-on-Zig initialized!');

  // Filter auto-submit / dynamic filter
  const filterForm = document.getElementById('filter-form');
  if (filterForm) {
    const speciesSelect = document.getElementById('species-select');
    const statusSelect = document.getElementById('status-select');

    if (speciesSelect) {
      speciesSelect.addEventListener('change', () => filterForm.submit());
    }
    if (statusSelect) {
      statusSelect.addEventListener('change', () => filterForm.submit());
    }
  }

  // Adoption modal handling
  const modal = document.getElementById('adoption-modal');
  const openButtons = document.querySelectorAll('.open-adoption-modal');
  const closeButton = document.querySelector('.modal-close');

  openButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const petId = btn.getAttribute('data-pet-id');
      const petName = btn.getAttribute('data-pet-name');

      const modalPetId = document.getElementById('modal-pet-id');
      const modalPetName = document.getElementById('modal-pet-name');

      if (modalPetId) modalPetId.value = petId;
      if (modalPetName) modalPetName.textContent = petName || 'Selected Pet';

      if (modal) modal.classList.add('active');
    });
  });

  if (closeButton && modal) {
    closeButton.addEventListener('click', () => {
      modal.classList.remove('active');
    });

    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.classList.remove('active');
      }
    });
  }
});
