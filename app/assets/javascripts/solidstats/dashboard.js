// Dashboard JavaScript functionality

// Create the Solidstats Dashboard namespace
window.SolidstatsDashboard = window.SolidstatsDashboard || {};

// Main dashboard initialization
window.SolidstatsDashboard.init = function() {
  handleUrlNavigation();
  setupEventListeners();
};

document.addEventListener('DOMContentLoaded', function() {
  window.SolidstatsDashboard.init();
});

function handleUrlNavigation() {
  // Parse URL hash for initial navigation
  const hash = window.location.hash.substring(1);
  if (hash) {
    const [section, tab] = hash.split('/');
    if (section) {
      setTimeout(() => {
        window.SolidstatsDashboard.navigateToSection(section, tab, true);
      }, 100);
    }
  }
}

function setupEventListeners() {
  window.SolidstatsDashboard.setupMainNavigation();
  window.SolidstatsDashboard.setupTabNavigation();
  window.SolidstatsDashboard.setupQuickNavigation();
  window.SolidstatsDashboard.setupSummaryCardNavigation();
}

// Function to update URL hash with current state
window.SolidstatsDashboard.updateUrlHash = function(section, tab = null) {
  let hash = '#' + section;
  if (tab) {
    hash += '/' + tab;
  }
  history.replaceState(null, null, hash);
};

// Function to navigate to section and tab
window.SolidstatsDashboard.navigateToSection = function(section, tab = null, shouldScroll = false) {
  // Remove active class from all nav items and sections
  document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
  document.querySelectorAll('.dashboard-section').forEach(section => section.classList.remove('active'));
  
  // Add active class to matching nav item
  const navItem = document.querySelector(`.nav-item[data-section="${section}"]`);
  if (navItem) {
    navItem.classList.add('active');
  }
  
  // Show corresponding section
  const sectionElement = document.getElementById(section);
  if (sectionElement) {
    sectionElement.classList.add('active');
    
    // If tab is specified, activate that tab
    if (tab) {
      const sectionEl = sectionElement;
      if (sectionEl) {
        // Deactivate all tabs first
        sectionEl.querySelectorAll('.tab-item').forEach(item => item.classList.remove('active'));
        sectionEl.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
        
        // Activate the target tab
        const targetTabItem = sectionEl.querySelector(`.tab-item[data-tab="${tab}"]`);
        const targetTabContent = sectionEl.querySelector(`#${tab}`);
        
        if (targetTabItem) targetTabItem.classList.add('active');
        if (targetTabContent) targetTabContent.classList.add('active');
      }
    }
    
    // Scroll to section if requested (with a small delay to ensure rendering)
    if (shouldScroll) {
      setTimeout(() => {
        sectionElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }, 100);
    }
    
    // Update URL hash
    window.SolidstatsDashboard.updateUrlHash(section, tab);
  }
};

// Main navigation
window.SolidstatsDashboard.setupMainNavigation = function() {
  document.querySelectorAll('.nav-item').forEach(function(navItem) {
    navItem.addEventListener('click', function(e) {
      e.preventDefault();
      
      // Get section ID from data attribute
      const sectionId = this.getAttribute('data-section');
      
      // Navigate to the section
      window.SolidstatsDashboard.navigateToSection(sectionId);
    });
  });
};

// Tab navigation
window.SolidstatsDashboard.setupTabNavigation = function() {
  document.querySelectorAll('.tab-item').forEach(function(tabItem) {
    if (!tabItem.hasAttribute('disabled')) {
      tabItem.addEventListener('click', function(e) {
        e.preventDefault();
        const tabContainer = this.closest('.dashboard-section');
        const tabId = this.getAttribute('data-tab');
        
        // Find the current active section
        const currentSection = tabContainer.id;
        
        // Remove active class from all tab items and tabs within this container
        tabContainer.querySelectorAll('.tab-item').forEach(item => item.classList.remove('active'));
        tabContainer.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
        
        // Add active class to clicked item and corresponding tab
        this.classList.add('active');
        const targetContent = tabContainer.querySelector(`#${tabId}`);
        if (targetContent) {
          targetContent.classList.add('active');
        }
        
        // Update URL hash with current section and tab
        window.SolidstatsDashboard.updateUrlHash(currentSection, tabId);
      });
    }
  });
};

// Quick navigation
window.SolidstatsDashboard.setupQuickNavigation = function() {
  document.querySelectorAll('.quick-nav-item').forEach(function(navItem) {
    navItem.addEventListener('click', function(e) {
      e.preventDefault();
      const targetId = this.getAttribute('href').substring(1);
      
      // Navigate to the specified section
      window.SolidstatsDashboard.navigateToSection(targetId);
      
      // Close the quick nav menu
      document.querySelector('.quick-nav-menu').style.display = 'none';
    });
  });
};

// Summary card navigation
window.SolidstatsDashboard.setupSummaryCardNavigation = function() {
  document.querySelectorAll('.summary-card').forEach(function(card) {
    card.addEventListener('click', function() {
      const section = this.getAttribute('data-section');
      const tab = this.getAttribute('data-tab');
      
      // Navigate to the specified section and tab, with scrolling
      window.SolidstatsDashboard.navigateToSection(section, tab, true);
    });
  });
};

// Notification system
window.SolidstatsDashboard.showNotification = function(message, type) {
  // Simple notification system
  const notification = document.createElement('div');
  notification.className = `notification notification-${type}`;
  notification.textContent = message;
  
  // Add to body
  document.body.appendChild(notification);
  
  // Remove after 3 seconds
  setTimeout(() => {
    notification.remove();
  }, 3000);
};
