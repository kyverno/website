/*
@TODO
 - Make listed filters collapseable in mobile.This would be help responsive issues
*/

// local storage 
const searchParams = new URLSearchParams(window.location.search);
const wstorage = window.localStorage;
const getStoredValues = JSON.parse(wstorage.getItem(storedValues));
let initialPolicies = getStoredValues ? getStoredValues.length ?  getStoredValues: [] : [];

let chosenPolicies = initialPolicies;

// elements' lookup
const policyWrap = elem(".policy_grid");
const appliedFiltersEl = elem(".filters_applied");
const section = elem(".td-section");

// add filters on the sidebar
function createFilterButton(filter, parent) {
  const id = "filter";
  const label = filter.trim();
  const buttonAlreadyExists = Array.from(elems(`.${id}`, parent)).filter(button => {
    return button.textContent.toLowerCase() === label.toLowerCase();
  });
  if(buttonAlreadyExists.length < 1) {
    let filterButton = createEl();
    filterButton.className = id;
    filterButton.textContent = label;
    parent.appendChild(filterButton);
  }
}

function populateFilters(data) {
  elem("#policy_filters").dataset.filters.split(",").forEach(function(filterType){
    let filters = new Set();
    data.forEach(function(item){
      item[filterType] ? filters.add(item[filterType]) : false;
    });
    let filterTypeEl = elem(`.filter_${filterType}`);
    const filterCategory = { "type": filterTypeEl.dataset.criteria, "policies": Array.from(filters) };
    allFiltersObj.push(filterCategory);

    if(data.length >= 1) {
      if (filters.size >= 1) {
        Array.from(filters).sort().forEach(function(filter){
          let actualFilters = filter.split(",");
          if(actualFilters.length > 1) {
            actualFilters.forEach(filter => {
              createFilterButton(filter, filterTypeEl);
            })
          } else {
            createFilterButton(filter, filterTypeEl);
          }
        });
      } else {
        filterTypeEl.classList.add("passive");
      }
    }
  });
}

function createPolicy(body, link, policy, title) {
  const policyElem = document.createElement("a");
  policyElem.className = "policy";
  policyElem.href = link;
  policy = policy.replaceAll(", ", "::").replaceAll(" ,", "::").replaceAll(",", "::");
  policyElem.dataset.policy = policy;
  const policyTitle = document.createElement("h3");
  policyTitle.className = "policy_title";
  policyTitle.textContent = title;
  const policyBody = document.createElement("p");
  policyBody.textContent = body;
  policyElem.appendChild(policyTitle);
  policyElem.appendChild(policyBody);
  return policyElem;
}

function listPolicies(data) {
  data.forEach(policy => {
    policy = createPolicy(policy.body, policy.link, policy.filters, policy.title);
    elem(".policy_wrap").appendChild(policy);
  });
}

function updateQuery() {
  let queryS = "";
  chosenPolicies.forEach((policy, index) => {
    let p = encodeURI(policy.type);
    queryS += index ? `+${p}` : p;
  });

  if (('URLSearchParams' in window) && queryS != undefined) {
    let newRelativePathQuery;
    if(queryS.length) {
      searchParams.set(policyTypeQueryString, queryS);
      newRelativePathQuery = window.location.pathname + '?' + searchParams.toString();
    } else {
      searchParams.delete(policyTypeQueryString);
      newRelativePathQuery = window.location.pathname;
    }
    history.pushState(null, '', newRelativePathQuery);
  }
}

function findQuery(query = policyTypeQueryString) {
  if(searchParams.has(query)){
    let c = searchParams.get(query);
    return decodeURI(c);
  }
  return "";
}

function sortQuery() {
  const queryObj = findQuery().split("+");
  let sharedFilters = [];
  const filtersObj = allFiltersObj;
  if(queryObj.length >= 1) {
    queryObj.forEach(phrase => {
      if(phrase.trim().length) {
        filtersObj.forEach(obj => {
          let policiesStr = obj.policies.join(" ").toLowerCase();
          policiesStr.includes(phrase.toLowerCase()) ? sharedFilters.push({"id": obj.type, "type": phrase}) : false;
        });
      }
    });
    // persist filters
    chosenPolicies = sharedFilters.length ? sharedFilters: chosenPolicies;
  }
}

function createButton(policy, id = null){
  const policyEl = createEl();
  let list = "button button_filter";
  list += (id === null) ? " button_clear" : "";
  policyEl.id = id;
  policyEl.className = list;
  policyEl.textContent = policy;
  return policyEl;
};

function listAppliedFilters() {
  appliedFiltersEl.innerHTML = "";
  chosenPolicies.sort((a, b) => a.type.localeCompare(b.type)).forEach(policy => {
    // check if filter is listed first;
    policy = policy.type;
    if(policy) {
      const id = `btn${sanitizeString(policy)}`;
      if(!elem(`#${id}`)) {
        const policyEl = createButton(policy, id);
        appliedFiltersEl.appendChild(policyEl);
      }
    }
  });
  if (chosenPolicies.length > 1) {
    
    appliedFiltersEl.appendChild(createButton("clear all"));
  }
}

function groupBy(list, keyGetter) {
  // function from https://codereview.stackexchange.com/questions/111704/group-similar-objects-into-array-of-arrays
  const map = new Map();
  list.forEach((item) => {
    const key = keyGetter(item);
    const collection = map.get(key);
    if (!collection) {
      map.set(key, [item]);
    } else {
      collection.push(item);
    }
  });
  return map;
}

function filterPolicies(obj=chosenPolicies) {
  const policies = elems(".policy");
  const results = elem(".filters_results");
  let resultsTally = 0;
  const grouped = groupBy(obj, item => item.id);
  let filtersPresent = new Set();
  
  // only apply to list page
  if(policies) {
    policies.forEach(policy => {
      const applicableFilters = policy.dataset.policy.split("::");
      let shouldList = false;
      let verdict = [];
      
      grouped.forEach(group => {
        const hasFilter = group.map(item => {
          const itemFilter = item.type;
          filtersPresent.add(itemFilter);
          return applicableFilters.includes(itemFilter);
        });
        const internalVerdict = hasFilter.includes(true);
        verdict.push(internalVerdict);
      });
      
      shouldList = verdict.includes(false) ? false : true;
      
      if(shouldList) {
        policy.classList.remove(hidden);
        resultsTally += 1;
      } else {
        policy.classList.add(hidden);
      }
    });
  }
  
  results.innerHTML = `<span>${resultsTally}</span> Policies Found`;
  
  filtersPresent = Array.from(filtersPresent);
  
  elems(".filter").forEach(button => {
    const id = button.textContent;
    const newObj = obj.map(entry => entry.type);
    filtersPresent = filtersPresent.length ? filtersPresent : newObj;
    filtersPresent.includes(id) ? button.classList.add(active) : button.classList.remove(active);
  });
  
  section ? listAppliedFilters() : false;
  
  !elem('.policy_page') ? updateQuery() : false;
}

function objIsInArray(obj,obj1) {
  let isEqual = [];
  obj.forEach((item, index) => {
    if(JSON.stringify(obj1) === JSON.stringify(item)) {
      isEqual.push(index);
    }
  });
  // returns index where object was found or null
  return isEqual.length ? isEqual[0] : null;
}

if(policyWrap) {
  window.addEventListener("click", event => {
    let obj = chosenPolicies;
    const target = event.target;
    const isFilter = target.matches(".filter");
    if(isFilter) {
      const filterType = target.textContent;
      let group = target.parentNode.dataset.criteria;
      filterGroup = Object.create(null);
      filterGroup.id = group;
      filterGroup.type = filterType;
      filtered = objIsInArray(obj, filterGroup);
      if (filtered != null) {
        obj.splice(filtered, 1);
      } else {
        obj.push(filterGroup);
      }
      
      // persist filters
      wstorage.setItem(storedValues, JSON.stringify(obj));
      
      filterPolicies();
      
      if(!section) {
        window.location.href = new URL("policies", rootURL).href;
      }
    }
    
    const isButton = target.matches(".button");
    if(isButton) {
      const isClearAll = target.matches(".button_clear");
      if(isClearAll) {
        chosenPolicies = [];
      } else {
        const thisPolicyType = target.textContent;
        const remainingPolicies = [];
        chosenPolicies.forEach((policy) => {
          if(policy.type != thisPolicyType) {
            remainingPolicies.push(policy);
          };
        });
        chosenPolicies = remainingPolicies;
      }
      // persist filters
      wstorage.setItem(storedValues, JSON.stringify(chosenPolicies));
      filterPolicies();
    }
    
    const isToggle = isTarget(target, ".policy_toggle");
    const filtersEl = elem(".policy_filters");

    containsClass(filtersEl, active) && !isToggle && !isTarget(target, ".policy_filters") ? deleteClass(filtersEl, active) : false;
    
    isToggle ? modifyClass(filtersEl, active) : false;
    
  });
  
  window.addEventListener('load', function() {
    // fetch file
    fetch(new URL("index.json", rootURL).href)
    .then(response => response.json())
    .then(function(data) {
      data = data.length ? data : [];
      data = data.sort((a, b) => a.title.localeCompare(b.title));
      section ? listPolicies(data) : false;
      // filter policies on load
      populateFilters(data);
      sortQuery();
      filterPolicies();
    })
    .catch((error) => console.error(error));
    
  });
}

(function goBack() {
    let backBtn = elem('.button_back');
    let history = window.history;
    if (backBtn) {
      backBtn.addEventListener('click', function(){
        history.back();
      });
    }
  })();
