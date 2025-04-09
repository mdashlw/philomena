function sortTable(table: HTMLTableElement, columnIndex: number, sortDirection: 'asc' | 'desc') {
  const tbody = table.tBodies[0];
  const rows = Array.from(tbody.rows);
  
  rows.sort((rowA, rowB) => {
      const cellA = rowA.cells[columnIndex].textContent || '';
      const cellB = rowB.cells[columnIndex].textContent || '';
      
      const numA = parseFloat(cellA.replace(/[^\d.-]/g, ''));
      const numB = parseFloat(cellB.replace(/[^\d.-]/g, ''));
      
      if (!isNaN(numA) && !isNaN(numB)) {
          return sortDirection === 'asc' ? numA - numB : numB - numA;
      }
      
      return sortDirection === 'asc' 
          ? cellA.localeCompare(cellB) 
          : cellB.localeCompare(cellA);
  });
  
  while (tbody.firstChild) {
      tbody.removeChild(tbody.firstChild);
  }
  
  rows.forEach((row, index) => {
      if (row.cells.length > 0) {
          row.cells[0].textContent = (index + 1).toString();
      }
      tbody.appendChild(row);
  });
}

export function setupTables() {
  document.querySelectorAll<HTMLTableElement>('table').forEach(table => {
      const headers = table.querySelectorAll<HTMLTableCellElement>('th[data-sortable-with-index]');
      
      headers.forEach((header) => {
          header.style.cursor = 'pointer';
          
          header.addEventListener('click', () => {
              let sortDirection: 'asc' | 'desc' = 'desc';
              const currentSortDir = header.getAttribute('data-sort-direction');
              
              if (currentSortDir === 'asc') {
                  sortDirection = 'desc';
              } else if (currentSortDir === 'desc') {
                  sortDirection = 'asc';
              }
              
              header.setAttribute('data-sort-direction', sortDirection);
              
              headers.forEach(h => {
                  if (h !== header) {
                      h.removeAttribute('data-sort-direction');
                  }
              });
              
              sortTable(table, header.cellIndex, sortDirection);
              
              header.classList.toggle('sorted-asc', sortDirection === 'asc');
              header.classList.toggle('sorted-desc', sortDirection === 'desc');
          });
      });
  });
}