// Enhanced Gem Metadata Interactive Features
document.addEventListener('DOMContentLoaded', function() {
  // Enhanced search and filter functionality
  const searchInput = document.getElementById('gem-search');
  const clearSearchBtn = document.getElementById('clear-search');
  const statusFilter = document.getElementById('status-filter');
  const sortFilter = document.getElementById('sort-filter');
  const resetFiltersBtn = document.getElementById('reset-filters');
  const gemsGrid = document.getElementById('gems-grid');
  const gemsTableContainer = document.getElementById('gems-table-container');
  const gemsTable = document.getElementById('gems-table');
  const gemsTableBody = document.getElementById('gems-table-body');
  const resultsInfo = document.getElementById('results-info');
  const resultsCount = document.getElementById('results-count');
  
  // View toggle elements
  const gridViewBtn = document.getElementById('grid-view-btn');
  const tableViewBtn = document.getElementById('table-view-btn');
  const exportGroup = document.getElementById('export-group');
  const exportTableBtn = document.getElementById('export-table-btn');
  
  // Export functionality
  function exportTableToCSV() {
    const csvData = [];
    
    // Header row
    csvData.push(['Gem Name', 'Status', 'Current Version', 'Latest Version', 'Released', 'Description', 'Dependencies']);
    
    // Data rows from filtered results
    filteredTableRows.forEach(row => {
      const cells = row.element.querySelectorAll('td');
      const rowData = [
        cells[0]?.textContent?.trim() || '',
        cells[1]?.textContent?.trim() || '',
        cells[2]?.textContent?.trim() || '',
        cells[3]?.textContent?.trim() || '',
        cells[4]?.textContent?.trim() || '',
        cells[5]?.textContent?.trim() || '',
        cells[6]?.textContent?.trim() || ''
      ];
      csvData.push(rowData);
    });
    
    // Convert to CSV format
    const csvContent = csvData.map(row => 
      row.map(field => `"${field.replace(/"/g, '""')}"`).join(',')
    ).join('\n');
    
    // Create and download file
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `gem-metadata-${new Date().toISOString().split('T')[0]}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    showToast('Table data exported successfully!', 'success');
  }
  
  // Loading state management
  const loadingOverlay = document.getElementById('loading-overlay');
  
  function showLoading() {
    if (loadingOverlay) {
      loadingOverlay.style.display = 'flex';
    }
  }
  
  function hideLoading() {
    if (loadingOverlay) {
      loadingOverlay.style.display = 'none';
    }
  }
  
  // Performance optimizations
  let searchTimeout;
  const SEARCH_DELAY = 300; // Debounce search for better performance
  
  // Optimized search with debouncing
  function debouncedSearch() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      performSearch();
    }, SEARCH_DELAY);
  }
  
  let allGems = [];
  let allTableRows = [];
  let filteredGems = [];
  let filteredTableRows = [];
  let currentView = 'grid'; // Default to grid view
  
  // Initialize gems data
  function initializeGems() {
    // Initialize grid cards
    allGems = Array.from(document.querySelectorAll('.gem-card-full')).map(card => {
      return {
        element: card,
        name: card.dataset.gemName,
        status: card.dataset.status,
        releaseDate: parseInt(card.dataset.releaseDate) || 0
      };
    });
    
    // Initialize table rows
    allTableRows = Array.from(document.querySelectorAll('.gem-table-row')).map(row => {
      return {
        element: row,
        name: row.dataset.gemName,
        status: row.dataset.status,
        releaseDate: parseInt(row.dataset.releaseDate) || 0
      };
    });
    
    filteredGems = [...allGems];
    filteredTableRows = [...allTableRows];
    updateResults();
  }
  
  // View toggle functionality
  function switchView(view) {
    currentView = view;
    
    if (view === 'grid') {
      // Show grid, hide table
      gemsGrid.style.display = 'grid';
      gemsTableContainer.style.display = 'none';
      gridViewBtn.classList.add('active');
      tableViewBtn.classList.remove('active');
      if (exportGroup) exportGroup.style.display = 'none';
      
      // Save preference
      localStorage.setItem('gems-view-preference', 'grid');
    } else {
      // Hide grid, show table
      gemsGrid.style.display = 'none';
      gemsTableContainer.style.display = 'block';
      tableViewBtn.classList.add('active');
      gridViewBtn.classList.remove('active');
      if (exportGroup) exportGroup.style.display = 'flex';
      
      // Save preference
      localStorage.setItem('gems-view-preference', 'table');
    }
    
    // Update results for current view
    updateResults();
  }
  
  // Load saved view preference
  function loadViewPreference() {
    const savedView = localStorage.getItem('gems-view-preference') || 'grid';
    switchView(savedView);
  }
  
  // Search functionality
  function performSearch() {
    const searchTerm = searchInput.value.toLowerCase().trim();
    const statusValue = statusFilter.value;
    
    // Filter grid cards
    filteredGems = allGems.filter(gem => {
      const matchesSearch = !searchTerm || gem.name.includes(searchTerm);
      const matchesStatus = !statusValue || gem.status === statusValue;
      return matchesSearch && matchesStatus;
    });
    
    // Filter table rows
    filteredTableRows = allTableRows.filter(row => {
      const matchesSearch = !searchTerm || row.name.includes(searchTerm);
      const matchesStatus = !statusValue || row.status === statusValue;
      return matchesSearch && matchesStatus;
    });
    
    applySorting();
    updateResults();
    updateClearButton();
  }
  
  // Sorting functionality
  function applySorting() {
    const sortValue = sortFilter.value;
    
    const sortFunction = (a, b) => {
      switch (sortValue) {
        case 'name-asc':
          return a.name.localeCompare(b.name);
        case 'name-desc':
          return b.name.localeCompare(a.name);
        case 'status-desc':
          const statusOrder = { 'outdated': 0, 'unavailable': 1, 'up-to-date': 2 };
          return (statusOrder[a.status] || 3) - (statusOrder[b.status] || 3);
        case 'release-desc':
          return b.releaseDate - a.releaseDate;
        case 'release-asc':
          return a.releaseDate - b.releaseDate;
        default:
          return 0;
      }
    };
    
    filteredGems.sort(sortFunction);
    filteredTableRows.sort(sortFunction);
  }
  
  // Update display
  function updateResults() {
    if (currentView === 'grid') {
      updateGridView();
    } else {
      updateTableView();
    }
    
    // Update results count
    const count = currentView === 'grid' ? filteredGems.length : filteredTableRows.length;
    if (resultsCount) {
      resultsCount.textContent = count;
    }
    
    // Show/hide empty state
    const isEmpty = count === 0;
    if (isEmpty && !document.querySelector('.filter-empty-state')) {
      showFilterEmptyState();
    } else if (!isEmpty) {
      hideFilterEmptyState();
    }
  }
  
  // Update grid view
  function updateGridView() {
    // Hide all gems first
    allGems.forEach(gem => {
      gem.element.style.display = 'none';
      gem.element.style.order = '';
    });
    
    // Show and order filtered gems
    filteredGems.forEach((gem, index) => {
      gem.element.style.display = 'block';
      gem.element.style.order = index;
      
      // Reset animation delay for visible items
      gem.element.style.animationDelay = `${index * 0.05}s`;
    });
  }
  
  // Update table view
  function updateTableView() {
    // Hide all table rows first
    allTableRows.forEach(row => {
      row.element.style.display = 'none';
    });
    
    // Show filtered rows
    filteredTableRows.forEach((row, index) => {
      row.element.style.display = '';
    });
  }
  
  // Show empty state for filters
  function showFilterEmptyState() {
    const emptyState = document.createElement('div');
    emptyState.className = 'filter-empty-state';
    emptyState.innerHTML = `
      <div class="empty-icon">🔍</div>
      <div class="empty-title">No matching gems found</div>
      <div class="empty-description">
        Try adjusting your search terms or filters to find what you're looking for.
      </div>
      <button class="action-btn refresh-btn" onclick="resetAllFilters()">
        <i class="fas fa-undo"></i>
        Clear Filters
      </button>
    `;
    
    if (currentView === 'grid') {
      emptyState.style.cssText = `
        grid-column: 1 / -1;
      `;
      gemsGrid.appendChild(emptyState);
    } else {
      // Add fallback class for better browser support
      gemsTableContainer.classList.add('has-empty-state');
      
      // For table view, create a properly centered empty state
      const emptyRow = document.createElement('tr');
      const emptyCell = document.createElement('td');
      emptyCell.colSpan = 7; // Span all columns
      emptyCell.className = 'empty-state-cell';
      emptyCell.style.height = '400px'; // Set fixed height for better centering
      emptyCell.appendChild(emptyState);
      emptyRow.appendChild(emptyCell);
      emptyRow.className = 'filter-empty-state-row';
      gemsTableBody.appendChild(emptyRow);
    }
  }
  
  // Hide filter empty state
  function hideFilterEmptyState() {
    const emptyState = document.querySelector('.filter-empty-state');
    const emptyRow = document.querySelector('.filter-empty-state-row');
    
    if (emptyState) {
      emptyState.remove();
    }
    
    if (emptyRow) {
      emptyRow.remove();
    }
    
    // Remove fallback class
    if (gemsTableContainer) {
      gemsTableContainer.classList.remove('has-empty-state');
    }
  }
  
  // Update clear search button visibility
  function updateClearButton() {
    const hasValue = searchInput.value.trim().length > 0;
    clearSearchBtn.style.display = hasValue ? 'block' : 'none';
  }
  
  // Reset all filters
  function resetAllFilters() {
    searchInput.value = '';
    statusFilter.value = '';
    sortFilter.value = 'name-asc';
    performSearch();
    updateClearButton();
  }
  
  // Global function for empty state button
  window.resetAllFilters = resetAllFilters;
  
  // Event listeners
  if (searchInput) {
    searchInput.addEventListener('input', debouncedSearch);
    searchInput.addEventListener('input', updateClearButton);
  }
  
  if (clearSearchBtn) {
    clearSearchBtn.addEventListener('click', function() {
      searchInput.value = '';
      performSearch();
      updateClearButton();
      searchInput.focus();
    });
  }
  
  if (statusFilter) {
    statusFilter.addEventListener('change', performSearch);
  }
  
  if (sortFilter) {
    sortFilter.addEventListener('change', function() {
      applySorting();
      updateResults();
    });
  }
  
  if (resetFiltersBtn) {
    resetFiltersBtn.addEventListener('click', resetAllFilters);
  }
  
  // View toggle event listeners
  if (gridViewBtn) {
    gridViewBtn.addEventListener('click', function() {
      switchView('grid');
    });
  }
  
  if (tableViewBtn) {
    tableViewBtn.addEventListener('click', function() {
      switchView('table');
    });
  }
  
  // Export functionality event listener
  if (exportTableBtn) {
    exportTableBtn.addEventListener('click', exportTableToCSV);
  }
  
  // Table sorting functionality
  if (gemsTable) {
    const sortableHeaders = gemsTable.querySelectorAll('th.sortable');
    sortableHeaders.forEach(header => {
      header.addEventListener('click', function() {
        const sortType = this.dataset.sort;
        const currentSort = sortFilter.value;
        
        // Toggle between asc/desc for the same column
        if (currentSort.startsWith(sortType)) {
          const isAsc = currentSort.endsWith('-asc');
          sortFilter.value = `${sortType}-${isAsc ? 'desc' : 'asc'}`;
        } else {
          sortFilter.value = `${sortType}-asc`;
        }
        
        // Update visual indicators
        sortableHeaders.forEach(h => h.classList.remove('sorted'));
        this.classList.add('sorted');
        
        applySorting();
        updateResults();
      });
    });
  }
  
  // Refresh button functionality with loading state
  const refreshBtn = document.querySelector('.refresh-btn');
  if (refreshBtn) {
    refreshBtn.addEventListener('click', function(e) {
      this.classList.add('loading');
      this.setAttribute('aria-busy', 'true');
      
      // Reset loading state after a delay (or when page reloads)
      setTimeout(() => {
        this.classList.remove('loading');
        this.removeAttribute('aria-busy');
      }, 3000);
    });
  }
  
  // Keyboard shortcuts
  document.addEventListener('keydown', function(e) {
    // Ctrl/Cmd + K to focus search
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
      e.preventDefault();
      searchInput.focus();
      searchInput.select();
    }
    
    // Escape to clear search when focused
    if (e.key === 'Escape' && document.activeElement === searchInput) {
      resetAllFilters();
      searchInput.blur();
    }
  });
  
  // Intersection Observer for staggered animations
  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
          entry.target.style.animationPlayState = 'running';
          observer.unobserve(entry.target);
        }
      });
    }, {
      threshold: 0.1,
      rootMargin: '50px'
    });
    
    // Observe all gem cards
    document.querySelectorAll('.gem-card-full').forEach(card => {
      card.style.animationPlayState = 'paused';
      observer.observe(card);
    });
  }
  
  // Update last updated time
  function updateLastUpdatedTime() {
    const lastUpdatedElement = document.getElementById('last-updated');
    if (lastUpdatedElement) {
      const now = new Date();
      const timeString = now.toLocaleTimeString([], { 
        hour: '2-digit', 
        minute: '2-digit' 
      });
      lastUpdatedElement.textContent = `${timeString}`;
    }
  }
  
  // Toast notifications
  function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast-notification ${type}`;
    toast.textContent = message;
    
    document.body.appendChild(toast);
    
    // Trigger animation
    setTimeout(() => toast.classList.add('visible'), 100);
    
    // Remove after delay
    setTimeout(() => {
      toast.classList.remove('visible');
      setTimeout(() => document.body.removeChild(toast), 300);
    }, 3000);
  }
  
  // Handle form submissions with toast feedback
  document.addEventListener('turbo:submit-start', function() {
    showToast('Refreshing gem metadata...', 'info');
  });
  
  document.addEventListener('turbo:submit-end', function(event) {
    if (event.detail.success) {
      showToast('Gem metadata updated successfully!', 'success');
      updateLastUpdatedTime();
    } else {
      showToast('Failed to update gem metadata. Please try again.', 'error');
    }
  });
  
  // Add loading animation to stats cards
  document.querySelectorAll('.stat-card').forEach((card, index) => {
    card.style.animationDelay = `${index * 0.1}s`;
    card.style.animation = 'fadeInUp 0.6s ease-out both';
  });
  
  // Enhanced keyboard navigation
  let currentCardIndex = -1;
  const cards = document.querySelectorAll('.gem-card-full');
  
  searchInput.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowDown' && filteredGems.length > 0) {
      e.preventDefault();
      currentCardIndex = 0;
      filteredGems[0].element.scrollIntoView({ behavior: 'smooth', block: 'center' });
      filteredGems[0].element.focus();
    }
  });
  
  // Add tabindex to cards for keyboard navigation
  cards.forEach((card, index) => {
    card.setAttribute('tabindex', '0');
    card.addEventListener('keydown', function(e) {
      if (e.key === 'ArrowDown' && currentCardIndex < filteredGems.length - 1) {
        e.preventDefault();
        currentCardIndex++;
        filteredGems[currentCardIndex].element.scrollIntoView({ behavior: 'smooth', block: 'center' });
        filteredGems[currentCardIndex].element.focus();
      } else if (e.key === 'ArrowUp' && currentCardIndex > 0) {
        e.preventDefault();
        currentCardIndex--;
        filteredGems[currentCardIndex].element.scrollIntoView({ behavior: 'smooth', block: 'center' });
        filteredGems[currentCardIndex].element.focus();
      } else if (e.key === 'Escape') {
        searchInput.focus();
        currentCardIndex = -1;
      }
    });
  });
  
  // Initialize on page load
  initializeGems();
  loadViewPreference(); // Load saved view preference
  updateClearButton();
  updateLastUpdatedTime();
});
