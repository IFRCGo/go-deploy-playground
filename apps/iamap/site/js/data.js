/* GO IA Map 2026 — content.
   Edit this file to change sections, pages, tabs, forms, links and the sitemap.
   Node fields: id (unique), s (section id), p (parent id), k (kind: page|tab|subtab|menu|form|list|dropdown|overlay|external|shortcut),
   t (title), d (description), a (access: LOGIN|IFRC|PERM), c (1 = upcoming), rep (repeat label), tags, eb (eyebrow),
   url (GO path), ext (external URL), chips, steps, acts: [[label, targetId, {sec, c, a, inert, self, ext}]]. */
const GO='https://go.ifrc.org';
// ---------- Sections ----------
const SECTIONS=[
 {id:'home',name:'Home',eb:'Main menu',icon:'home',d:'The landing page, its presentation overlay and the full-length lists that its “View all” links open.'},
 {id:'countries',name:'Countries',eb:'Main menu',icon:'globe',d:'Five IFRC regions and every country of the 191 member National Societies. Each region and country has its own page, with tabs and sub-tabs.'},
 {id:'prepare',name:'Prepare',eb:'Main menu',icon:'shield',d:'Global risk analysis, the Preparedness for Effective Response (PER) approach, and supply chain preparedness.'},
 {id:'respond',name:'Respond',eb:'Main menu',icon:'alert',d:'Ongoing emergencies and the emergency page, the DREF and its two pillars, and surge deployments. The emergency page is the hub most flows pass through.'},
 {id:'learn',name:'Learn',eb:'Main menu',icon:'book',d:'Operational learning, tools and resources. Several Learn links are shortcuts to pages that live under Respond or Prepare.'},
 {id:'account',name:'Account & utilities',eb:'Top bar & footer',icon:'gear',d:'Search, language, login and registration, My Account, the GO back-end and the footer pages.'},
 {id:'forms',name:'Forms',eb:'Logged in',icon:'pen',d:'Every form opened from “Create a Report”, the red action buttons and My Forms. A saved or submitted form is listed in My Forms.'}
];

// ---------- Nodes ----------
// k: page|tab|subtab|menu|form|list|dropdown|overlay|external|shortcut · a: login|ifrc|perm · c: upcoming · rep · tags · retire · url (GO path) · ext (absolute URL) · acts:[label,target,flags]
const N=[]; const add=o=>{N.push(o);return o};
const LOGIN='login', IFRC='ifrc', PERM='perm';

// HOME
add({id:'home',s:'home',k:'page',t:'Home',big:1,url:'/',
 d:'The landing page with the global picture of IFRC disaster response: key figures (active DREF operations, active emergency appeals, funding requirements, funding coverage, targeted population), the active operations map and the highlighted operations.',
 acts:[['Operation card / map','emergency'],['Follow','acct-notifications',{a:LOGIN,sec:1}],['View all Operations','lists',{sec:1}],['View all Emergencies','lists',{sec:1}],['Presentation Mode','presentation',{sec:1}]]});
add({id:'presentation',s:'home',p:'home',k:'overlay',t:'Presentation Mode',
 d:'Full-screen view of the active operations map with the key figures above it, for screens and meetings. Opened from the map on Home; the same map component offers it on region and country pages.'});
add({id:'lists',s:'home',k:'list',t:'Lists',
 d:'Full-length, filterable tables opened by “View all” links on Home, the emergency, region, country and surge pages.',
 chips:['All Appeals','All Emergencies','All Field Reports','All Flash Updates · IFRC only','All Surge Alerts','All Deployed Personnel','All Deployed ERUs'],
 urlNote:'/appeals/all · /emergencies/all · /field-reports/all · /flash-updates/all · /alerts/all · /deployed-personnels/all · /deployed-erus/all',
 acts:[['Emergency row','emergency'],['Report row','report-detail',{sec:1}]]});

// COUNTRIES
add({id:'region',s:'countries',k:'page',t:'Region page',big:1,rep:'×5',url:'/regions/:regionId',
 d:'One page per IFRC region with regional key figures, its operations, risk, profile and the countries in the region.',
 chips:['Africa','Americas','Asia Pacific','Europe','Middle East and North Africa'],acts:[['Country in the region','country']]});
add({id:'region-operations',s:'countries',p:'region',k:'tab',t:'Operations',url:'/regions/:regionId/operations',d:'Active emergency operations in the region, with key figures, the operations map and highlighted operations.',acts:[['Operation card','emergency',{sec:1}],['View all','lists',{sec:1}]]});
add({id:'region-riskwatch',s:'countries',p:'region',k:'tab',t:'Risk Watch',url:'/regions/:regionId/risk-watch',d:'Hazard risk for the region, split into two sub-tabs.'});
add({id:'region-imminent',s:'countries',p:'region-riskwatch',k:'subtab',t:'Imminent',url:'/regions/:regionId/risk-watch/imminent',d:'Forecasted and ongoing hazards in the region and their modelled impact on people and places.'});
add({id:'region-seasonal',s:'countries',p:'region-riskwatch',k:'subtab',t:'Seasonal',url:'/regions/:regionId/risk-watch/seasonal',d:'Seasonal or recurrent risk per country, per month, for each hazard type, based on historical events.'});
add({id:'region-profile',s:'countries',p:'region',k:'tab',t:'Regional Profile',url:'/regions/:regionId/profile',d:'The region’s National Societies, the regional office contacts and key links.'});
add({id:'region-additional',s:'countries',p:'region',k:'tab',t:'Additional Info',url:'/regions/:regionId/additional-info',tags:['Custom title'],d:'Custom content added by the regional office. Each region can rename the tab, for example to “Regional Information”. Shown only when the region has content.'});

add({id:'country',s:'countries',k:'page',t:'Country page',big:1,rep:'×1 per country',url:'/countries/:countryId',
 d:'Everything about one country and its National Society: ongoing emergencies, the National Society overview, the country profile and custom content.',
 acts:[['Region link','region',{sec:1}],['Edit Country','admin',{a:PERM,sec:1,ext:1}]]});
add({id:'c-ongoing',s:'countries',p:'country',k:'tab',t:'Ongoing Activities',url:'/countries/:countryId/ongoing-activities',d:'What is happening in the country now.'});
add({id:'c-emergencies',s:'countries',p:'c-ongoing',k:'subtab',t:'Ongoing Emergencies',url:'/countries/:countryId/ongoing-activities/emergencies',d:'Active operations in the country, with key figures, the map and the emergencies table.',acts:[['Operation card','emergency',{sec:1}],['View all','lists',{sec:1}]]});
add({id:'c-eap',s:'countries',p:'c-ongoing',k:'subtab',t:'EAP details',c:1,d:'The country’s Early Action Protocols and their status.',acts:[['EAP activation / reports','form-eap-activation',{c:1}]]});
add({id:'c-ns',s:'countries',p:'country',k:'tab',t:'National Society Overview',url:'/countries/:countryId/ns-overview',d:'Who the National Society is and what it does, in five sub-tabs.'});
add({id:'c-ns-activities',s:'countries',p:'c-ns',k:'subtab',t:'NS Activities',url:'/countries/:countryId/ns-overview/activities',d:'What the National Society does, by sector, and with which partners.'});
add({id:'c-context',s:'countries',p:'c-ns',k:'subtab',t:'Context and Structure',url:'/countries/:countryId/ns-overview/context-and-structure',d:'Key facts, governance and structure, local units and contacts of the National Society.'});
add({id:'c-strategic',s:'countries',p:'c-ns',k:'subtab',t:'Strategic Priorities',url:'/countries/:countryId/ns-overview/strategic-priorities',d:'The National Society’s strategic priorities and country plans.'});
add({id:'c-capacity',s:'countries',p:'c-ns',k:'subtab',t:'Capacity',url:'/countries/:countryId/ns-overview/capacity',
 d:'Organisational Capacity Assessments and the PER section: each PER cycle with its phase, type of assessment, focal point and date.',
 acts:[['Start PER Process','form-per',{a:LOGIN}],['View completed PER','country-per',{a:PERM,sec:1}]]});
add({id:'c-partners',s:'countries',p:'c-ns',k:'subtab',t:'Partners',url:'/countries/:countryId/ns-overview/partners',d:'Supporting partners and the support they provide.'});
add({id:'country-per',s:'countries',p:'country',k:'page',t:'Completed PER page',a:PERM,url:'/countries/:countryId/ns-overview/per/:perId',
 d:'Standalone page with the results of one completed PER assessment for the National Society. Opened from Capacity; visible only with specific permissions.',acts:[['Export','country-per',{sec:1,self:1}]]});
add({id:'c-profile',s:'countries',p:'country',k:'tab',t:'Country Profile',url:'/countries/:countryId/profile',d:'Country indicators, risk and past events, in three sub-tabs.'});
add({id:'c-overview',s:'countries',p:'c-profile',k:'subtab',t:'Overview',url:'/countries/:countryId/profile/overview',d:'Key country indicators and figures.'});
add({id:'c-riskwatch',s:'countries',p:'c-profile',k:'subtab',t:'Risk Watch',url:'/countries/:countryId/profile/risk-watch',d:'Seasonal risk and imminent hazards for the country.'});
add({id:'c-previous',s:'countries',p:'c-profile',k:'subtab',t:'Previous Events',url:'/countries/:countryId/profile/previous-events',d:'Past disasters and operations in the country.'});
add({id:'c-additional',s:'countries',p:'country',k:'tab',t:'Additional Info',url:'/countries/:countryId/additional-info',tags:['Custom title'],d:'Custom content for the country. Members of the National Society can rename the tab.'});

// PREPARE
add({id:'risk-watch',s:'prepare',k:'page',eb:'Risk Analysis',t:'Risk Watch',url:'/risk-watch',d:'The global risk overview: the magnitude of risk per country, per month, based on historical events and risk analysis.'});
add({id:'rw-imminent',s:'prepare',p:'risk-watch',k:'tab',t:'Imminent',url:'/risk-watch/imminent',d:'Forecasted and ongoing hazards worldwide and their modelled impact on people and places.'});
add({id:'rw-seasonal',s:'prepare',p:'risk-watch',k:'tab',t:'Seasonal',url:'/risk-watch/seasonal',d:'Seasonal or recurrent risk per country, per month, by hazard type, from historical events.'});
add({id:'per',s:'prepare',k:'page',t:'Preparedness for Effective Response (PER)',url:'/preparedness',
 d:'The PER approach is a continuous, flexible process that lets National Societies assess, measure and analyse the strengths and gaps of their preparedness and response.',
 acts:[['Start PER Process','form-per',{a:LOGIN}],['My PER Applications','acct-forms-per',{a:LOGIN,sec:1}]]});
add({id:'per-summary',s:'prepare',p:'per',k:'tab',t:'Global Summary',url:'/preparedness/global-summary',d:'Where each National Society is in the PER process, on a map and in a table.'});
add({id:'per-performance',s:'prepare',p:'per',k:'tab',t:'Global Performance',url:'/preparedness/global-performance',d:'Aggregated assessment results across PER components and regions.'});
add({id:'per-catalogue',s:'prepare',p:'per',k:'tab',t:'Catalogue of Resources',url:'/preparedness/resources-catalogue',d:'PER guidance, tools and learning materials for strengthening preparedness capacity.'});
add({id:'spark',s:'prepare',k:'page',eb:'Supply Chain',t:'SPARK',a:LOGIN,url:'/spark',d:'Supply chain Preparedness Analysis and Response Knowledge: a dashboard of stock, warehouses and supply chain data.'});

// RESPOND
add({id:'ongoing',s:'respond',k:'page',eb:'Emergencies',t:'Ongoing Emergencies',url:'/emergencies',
 d:'Emergencies of the last 30 days: key figures (affected people, requested amount, funding), the map, emergencies by type and over the last year, and the emergencies table.',
 acts:[['Create Field Report','form-field',{a:LOGIN}],['Emergency row','emergency']]});
add({id:'emergency',s:'respond',p:'ongoing',k:'page',t:'Emergency page',big:1,rep:'×1 per emergency',url:'/emergencies/:emergencyId',
 d:'The page of one emergency or operation, where its reports, documents, deployments and learning come together. Tabs appear depending on the operation stage (field report, DREF, emergency appeal).',
 acts:[['Follow / Unfollow','acct-notifications',{a:LOGIN,sec:1}],['Region / country link','country',{sec:1}],['Edit Event','admin',{a:PERM,sec:1,ext:1}]]});
add({id:'em-overview',s:'respond',p:'emergency',k:'tab',t:'Emergency Overview',url:'/emergencies/:emergencyId/details',d:'Key figures, operation timeline, funding and a summary of the situation.'});
add({id:'em-actions',s:'respond',p:'emergency',k:'tab',t:'Actions Summary',tags:['Field report stage only'],url:'/emergencies/:emergencyId/actions-summary',d:'Actions taken so far, compiled from field reports. Shown only before a DREF or appeal is launched.'});
add({id:'em-strategy',s:'respond',p:'emergency',k:'tab',t:'Operation Strategy',tags:['DREF only'],url:'/emergencies/:emergencyId/operation-strategy',d:'Planned response and needs by sector from the DREF application.'});
add({id:'em-docs',s:'respond',p:'emergency',k:'tab',t:'Documents',url:'/emergencies/:emergencyId/documents',d:'Field reports, flash updates, appeal documents and other operation documents.',acts:[['Field report','report-detail',{sec:1}]]});
add({id:'em-surge',s:'respond',p:'emergency',k:'tab',t:'Surge',url:'/emergencies/:emergencyId/surge',d:'Surge alerts, rapid response personnel and ERU deployments for this emergency. Hidden at the field report stage.'});
add({id:'em-background',s:'respond',p:'emergency',k:'tab',t:'Background',url:'/emergencies/:emergencyId/background',d:'The event, its impact and context, and the Operational Learnings related to it.',acts:[['Operational Learning','ol',{sec:1}]]});
add({id:'em-additional',s:'respond',p:'emergency',k:'tab',t:'Additional Info tabs',tags:['Custom title','Up to 3'],url:'/emergencies/:emergencyId/additional-info-1',d:'Custom tabs added by the operation team. Each can be renamed; large emergencies can have up to three.'});
add({id:'em-eap',s:'respond',p:'emergency',k:'tab',t:'EAP Activation emergency pages',c:1,d:'EAP Activation is coming as a new emergency type, with its own page layout and tabs.',acts:[['Submit update / EAP report','form-eap-activation',{c:1}]]});

add({id:'dref',s:'respond',k:'page',eb:'Disaster Response Emergency Fund (DREF)',t:'Disaster Response Emergency Fund (DREF)',url:'/dref',
 d:'The main hub for how the DREF works: rapid, reliable funding for National Societies to prepare for and respond to crises, how to choose the right modality, and active operations.',
 acts:[['Create DREF Application','form-dref',{a:LOGIN}],['DREF Decision Tree','dref-tree',{sec:1}],['My DREF Applications','acct-forms-dref',{a:LOGIN,sec:1}],['My Early Action Protocols','acct-forms-eap',{a:LOGIN,sec:1}]]});
add({id:'dref-tree',s:'respond',p:'dref',k:'overlay',t:'DREF Decision Tree',d:'Interactive questions that point to the right DREF modality. Opens as an overlay on the DREF page and on both pillar tabs.'});
add({id:'dref-anticipatory',s:'respond',p:'dref',k:'tab',t:'Anticipatory Pillar',url:'/dref/anticipatory-pillar',
 d:'Funding to act before a disaster strikes, based on pre-agreed triggers and plans approved in peacetime.',acts:[['DREF Decision Tree','dref-tree',{sec:1}]]});
add({id:'dref-imminent',s:'respond',p:'dref-anticipatory',k:'subtab',t:'Imminent DREF',d:'For sudden-onset events that have not happened yet, where the National Society has no EAP in place. A short template with quick approval.',acts:[['Start Imminent DREF','form-dref',{a:LOGIN}]]});
add({id:'dref-eap',s:'respond',p:'dref-anticipatory',k:'subtab',t:'Early Action Protocols (EAP)',d:'Plans for early action against a forecasted hazard, developed and approved in peacetime, combining triggers, actions and pre-positioned funding.',acts:[['Register EAP','form-eap-reg',{a:LOGIN}]]});
add({id:'dref-response',s:'respond',p:'dref',k:'tab',t:'Response Pillar',url:'/dref/response-pillar',
 d:'Funding for small and medium emergencies, sudden or slow onset: Response DREF grants and DREF Loans. An Emergency Advance Payment gives up to CHF 30,000 (yellow) or CHF 100,000 (orange/red) within 24 hours of a sudden-onset disaster, while the full application is prepared.',
 acts:[['DREF Application Form','form-dref',{a:LOGIN}],['DREF Decision Tree','dref-tree',{sec:1}],['Emergency Advance Payment Form','form-dref-advance',{c:1}]]});

add({id:'surge',s:'respond',k:'page',eb:'Surge/Deployments',t:'Surge',url:'/surge',
 d:'Who is deployed where, with key figures (active rapid response personnel, deployments this year, active ERUs), plus the tools and services available to responders.'});
add({id:'surge-active',s:'respond',p:'surge',k:'tab',t:'Active Surge Deployments',url:'/surge/active-surge-deployments',d:'Ongoing deployments by emergency, on a map and in a table.',acts:[['View all','lists',{sec:1}]]});
add({id:'surge-overview',s:'respond',p:'surge',k:'tab',t:'Surge Global Overview',url:'/surge/overview',d:'Open surge alerts and deployments worldwide. Shown on the page as the “Surge Overview” tab, with two sub-tabs.',acts:[['All Surge Alerts','lists',{sec:1}]]});
add({id:'surge-rrp',s:'respond',p:'surge-overview',k:'subtab',t:'Rapid Response Personnel',url:'/surge/overview/rapid-response-personnel',d:'Deployed rapid response personnel by profile, emergency and National Society.'});
add({id:'surge-eru',s:'respond',p:'surge-overview',k:'subtab',t:'Emergency Response Unit',url:'/surge/overview/emergency-response-unit',d:'Deployed ERUs and the readiness of each ERU type.',acts:[['Update ERU Readiness','form-eru',{a:LOGIN}]]});
add({id:'surge-toolbox',s:'respond',p:'surge',k:'tab',t:'Operational Toolbox',url:'/surge/operational-toolbox',d:'A central repository of key operational documents for missions: templates, checklists, guidance and examples. Also linked from Learn › Tools.'});
add({id:'surge-catalogue',s:'respond',p:'surge',k:'tab',t:'Catalogue of Surge Services',rep:'×n',url:'/surge/catalogue',
 d:'Every surge service by area, each with its own page and sub-pages describing the team, kit and capacity.',
 chips:['Health','Logistics','WASH','Shelter','Information Management','Cash','Relief','PGI','and more']});
add({id:'surge-dashboard',s:'respond',p:'surge',k:'tab',t:'Surge dashboard',c:1,d:'Overview of alerts, RR and ERU deployments and appraisals.'});

// LEARN
add({id:'ol',s:'learn',k:'page',eb:'Operational Learning',t:'Operational Learning',url:'/operational-learning',
 d:'Lessons learned from managing emergencies, filterable by region, country, disaster type, sector and component, with an AI-assisted summary of learning and its sources.',acts:[['Source data','montandon',{sec:1}]]});
add({id:'tools',s:'learn',k:'menu',t:'Tools',d:'Menu section with two links. One is a shortcut to a Surge tab, the other opens an external tool.'});
add({id:'tools-toolbox',s:'learn',p:'tools',k:'shortcut',t:'Operational Toolbox',to:'surge-toolbox'});
add({id:'survey',s:'learn',p:'tools',k:'external',t:'Survey Designer',ext:true,extLabel:'IFRC KoboToolbox',d:'Build standardised needs-assessment surveys quickly and publish them in IFRC KoboToolbox.'});
add({id:'resources',s:'learn',k:'menu',t:'Resources',d:'Menu section with four links: two pages under Learn and two shortcuts to catalogues under Respond and Prepare.'});
add({id:'montandon',s:'learn',p:'resources',k:'page',t:'Montandon – the Global Crisis Data Bank',url:'/montandon-landing',d:'The world’s largest disaster database: forecasted and observed hazards, their impacts, and the actions taken. Links to the API and data browser.'});
add({id:'go-resources',s:'learn',p:'resources',k:'page',t:'GO Resources',url:'/resources',d:'GO user guidance, reference materials, reference videos, other IFRC resources and GO contacts.'});
add({id:'res-surge',s:'learn',p:'resources',k:'shortcut',t:'Catalogue of Surge Services',to:'surge-catalogue'});
add({id:'res-per',s:'learn',p:'resources',k:'shortcut',t:'PER Catalogue of Resources',to:'per-catalogue'});
add({id:'blog',s:'learn',k:'external',eb:'GO Blog',t:'GO Blog',ext:'https://ifrcgoproject.medium.com',extLabel:'Medium',d:'News, release notes and stories from the GO team.'});

// ACCOUNT & UTILITIES
add({id:'search',s:'account',k:'page',t:'Search results',url:'/search',
 d:'Results for a keyword (3 characters or more), grouped into emergencies, reports, open surge alerts, deployed ERUs, rapid response deployments, countries, regions and provinces.',
 acts:[['Emergency','emergency',{sec:1}],['Report','report-detail',{sec:1}],['Country','country',{sec:1}],['Region','region',{sec:1}],['Surge alerts and deployments','lists',{sec:1}]]});
add({id:'language',s:'account',k:'dropdown',t:'Language',d:'Switches the interface language. Arabic switches the layout to right-to-left.',chips:['English','Français','Español','Arabic']});
add({id:'login',s:'account',k:'page',t:'Login',url:'/login',
 d:'For staff, members and volunteers of the Red Cross Red Crescent Movement. Sign in with email or username and password.',
 acts:[['Login','my-account'],['Forgot your password/username?','recover',{sec:1}],['I didn’t get my validation email','resend',{sec:1}],['Sign up','register',{sec:1}]]});
add({id:'register',s:'account',k:'page',t:'Register',url:'/register',d:'Create a GO account. Users without an official Red Cross Red Crescent email add a justification and are verified by the GO team.',acts:[['Login','login',{sec:1}]]});
add({id:'recover',s:'account',p:'login',k:'page',t:'Recover Account',url:'/recover-account',d:'Step 1 of the forgot-password flow: enter the registration email to receive a recovery link.',acts:[['Email link','recover-confirm',{sec:1}]]});
add({id:'recover-confirm',s:'account',p:'login',k:'page',t:'Recover Account Confirm',url:'/recover-account/:username/:token',d:'Step 2: opened from the emailed link. Set a new password, then log in.',acts:[['Login','login',{sec:1}]]});
add({id:'resend',s:'account',p:'login',k:'page',t:'Resend Validation Email',url:'/resend-validation-email',d:'Sends the account validation email again for users who did not receive it after registering.'});
add({id:'my-account',s:'account',k:'page',t:'My Account',big:1,a:LOGIN,url:'/account',d:'The user’s personal space: profile details, submitted forms and notifications.'});
add({id:'acct-details',s:'account',p:'my-account',k:'tab',t:'Account Details',url:'/account/details',
 d:'Profile and organisation details, password change, and external connections: generate a token to use the GO API in other platforms and dashboards.',
 acts:[['Edit Profile','acct-details',{sec:1,self:1,inert:1}],['Change Password','acct-details',{sec:1,self:1,inert:1}],['Generate Token (GO API)','acct-details',{self:1,inert:1}]]});
add({id:'acct-forms',s:'account',p:'my-account',k:'tab',t:'My Forms',url:'/account/my-forms',d:'Everything the user has drafted or submitted, in four sub-tabs.'});
add({id:'acct-forms-fr',s:'account',p:'acct-forms',k:'subtab',t:'Field Report',url:'/account/my-forms/field-report',d:'The user’s field reports, with edit and view links.',acts:[['Create a Field Report','form-field',{a:LOGIN}],['View report','report-detail',{sec:1}]]});
add({id:'acct-forms-per',s:'account',p:'acct-forms',k:'subtab',t:'PER',url:'/account/my-forms/per',d:'PER processes the user can see or edit, by country and phase.',acts:[['Start PER Process','form-per',{a:LOGIN}]]});
add({id:'acct-forms-dref',s:'account',p:'acct-forms',k:'subtab',t:'DREF Applications',url:'/account/my-forms/dref',d:'DREF applications with their operational updates and final reports.',acts:[['Start DREF Application','form-dref',{a:LOGIN}],['New Operational Update','form-dref-ops',{sec:1}],['Final Report','form-dref-final',{sec:1}]]});
add({id:'acct-forms-eap',s:'account',p:'acct-forms',k:'subtab',t:'EAP Applications',url:'/account/my-forms/eap-applications',d:'EAP registrations and applications with status: technically validated, approved, project agreement signed.',acts:[['Register EAP','form-eap-reg',{a:LOGIN}],['Continue full EAP','form-eap-full',{sec:1}],['Continue simplified EAP','form-eap-simple',{sec:1}]]});
add({id:'acct-notifications',s:'account',p:'my-account',k:'tab',t:'Notifications',url:'/account/notifications',d:'Subscription preferences (weekly digest, platform updates, GO briefings) and the operations the user follows.'});
add({id:'report-detail',s:'account',k:'page',t:'Report detail pages',rep:'×n',retire:'Retiring soon',url:'/field-reports/:fieldReportId',d:'Read-only view of one submitted field report or flash update. These standalone pages will soon be retired.',chips:['Field report','Flash update']});
add({id:'admin',s:'account',k:'external',t:'GO admin (back-end)',a:PERM,ext:'https://goadmin.ifrc.org/admin/',extLabel:'Back-end',d:'Django admin where users with specific permissions edit country details, events and other records. Reached from “Edit Country” and “Edit Event”.'});
add({id:'terms',s:'account',k:'page',eb:'Footer',t:'Terms and Conditions',url:'/terms-and-conditions',d:'Terms of use for the GO platform and its data.'});
add({id:'cookie',s:'account',k:'page',eb:'Footer',t:'Cookie Policy',url:'/cookie-policy',d:'How GO uses cookies and analytics.'});
add({id:'footer-ext',s:'account',k:'external',eb:'Footer',t:'Footer external links',d:'Links that leave GO. No action inside the platform.',
 chips:['Open Source Code · GitHub','API Documentation','GO Wiki'],links:[['Open Source Code','https://github.com/ifrcgo/go-web-app'],['API Documentation','https://goadmin.ifrc.org/docs'],['GO Wiki','https://go-wiki.ifrc.org']]});

// FORMS
const AS=['After saving','acct-forms',{sec:1}];
const F=(id,t,steps,o={})=>add(Object.assign({id,s:'forms',k:'form',t,a:LOGIN,steps,acts:[AS]},o));
F('form-field','Field report',['Context','Situation (Risk Analysis for early action)','Actions (Early Actions)','Response'],{url:'/field-reports/new',
 d:'Reports a new event or an early warning / early action. Creates or updates an emergency page.',
 acts:[['After saving','acct-forms-fr',{sec:1}],['EAP Activation Notification Field Report','form-eap-activation',{c:1}],['Emergency Advance Payment','form-dref-advance',{c:1}]]});
F('form-flash','Flash update',['Context','Actions','Focal Points'],{a:IFRC,url:'/flash-updates/new',d:'Short IFRC situation update shared with the Movement in the first days of an event.'});
F('form-dref','DREF application',['Operation Overview','Event Detail','Actions/Needs','Operation','Operational timeframes and contacts'],{url:'/dref-applications/new',
 d:'Requests DREF funding (Response or Imminent). The same form is the base for operational updates and final reports.',acts:[['After saving','acct-forms-dref',{sec:1}]]});
F('form-dref-ops','DREF operational update',['Operation Overview','Event Detail','Actions/Needs','Operation','Operational timeframes and contacts'],{url:'/dref-operational-updates/:opsUpdateId/edit',d:'Reports progress or changes (timeframe, budget, scope) on an approved DREF.',acts:[['After saving','acct-forms-dref',{sec:1}]]});
F('form-dref-final','DREF final report',['Operation Overview','Event Detail','Event Development','Actions/Needs','Operation','Implementation','Operational timeframes and contacts'],{url:'/dref-final-reports/:finalReportId/edit',d:'Closes a DREF operation with results, implementation and lessons learned.',acts:[['After saving','acct-forms-dref',{sec:1}]]});
F('form-per','PER process',['Overview','Assessment','Prioritization','Work-Plan'],{url:'/per-process/new',d:'Takes a National Society through one PER cycle, from overview to work plan.',acts:[['After saving','acct-forms-per',{sec:1}]]});
F('form-eap-reg','EAP registration',null,{url:'/eap-registration/new',d:'One page. Registers the development of an EAP and leads to the EAP or simplified EAP form.',acts:[['After saving','acct-forms-eap',{sec:1}],['EAP','form-eap-full',{sec:1}],['Simplified EAP','form-eap-simple',{sec:1}]]});
F('form-eap-full','EAP',['Overview','Risk Analysis','Trigger Model','Selection of Actions','EAP Activation Process','MEAL','National Society Capacity','Finance and Logistics'],{url:'/eap/:eapId/full',d:'The full Early Action Protocol, for multi-year plans against a forecasted hazard.',acts:[['After saving','acct-forms-eap',{sec:1}]]});
F('form-eap-simple','Simplified EAP',['Overview','Risk Analysis & Early Action Selection','Early Action Intervention','Planned Operations','Enabling Approaches','Conditions to deliver & budgets'],{url:'/eap/:eapId/simplified',d:'A lighter EAP with a shorter template.',acts:[['After saving','acct-forms-eap',{sec:1}]]});
F('form-eru','ERU readiness',null,{url:'/eru-readiness',d:'One page. ERU-hosting National Societies update the readiness of their units.',acts:[['After saving','surge-eru',{sec:1}]]});
F('form-dref-advance','DREF advance payment',['Emergency overview'],{c:1,d:'Requests an Emergency Advance Payment within 24 hours of a sudden-onset disaster.'});
F('form-eap-activation','EAP activation & reports',['EAP activation','Operational update','Activation report','Annual report','Final report'],{c:1,d:'Activates an approved EAP when its trigger is reached, then reports on it.',acts:[['After saving','acct-forms-eap',{sec:1,c:1}],['Publishes emergency page','em-eap',{c:1,sec:1}]]});

// ---------- Sitemap (menu as users see it) ----------
// link: [label, target, flags] flags: dd (dropdown item), act (action), ext, rep (repeat text), ifrc, plain
const SM=[
 {zone:'Main menu',cols:[
  {t:'Home',sp:1,icon:'home',go:'home',groups:[[null,[['Home','home']]]]},
  {t:'Countries',sp:2,icon:'globe',go:'region',note:'Every country of the 191 member National Societies',groups:[[null,[['5 regions and their countries','region',{dd:1}],['Region page','region',{tag:'×5'}],['Country page','country',{tag:'×1 per country'}]]]]},
  {t:'Prepare',sp:2,icon:'shield',go:'risk-watch',groups:[['Risk Analysis',[['Risk Watch','risk-watch']]],['Preparedness for Effective Response (PER)',[['Global Summary','per-summary'],['Global Performance','per-performance'],['Catalogue of Resources','per-catalogue']]],['Supply Chain',[['SPARK','spark']]]]},
  {t:'Respond',sp:3,icon:'alert',go:'ongoing',groups:[['Emergencies',[['Ongoing Emergencies','ongoing']]],['Early Warning',[['Create Early Action Field Report','form-field',{act:1}],['Create Flash Update','form-flash',{act:1,ifrc:1}]]],['Disaster Response Emergency Fund (DREF)',[['Anticipatory Pillar','dref-anticipatory'],['Response Pillar','dref-response']]],['Surge/Deployments',[['Active Surge Deployments','surge-active'],['Surge Global Overview','surge-overview'],['Operational Toolbox','surge-toolbox'],['Catalogue of Surge Services','surge-catalogue']]]]},
  {t:'Learn',sp:3,icon:'book',go:'ol',groups:[['Operational Learning',[['Operational Learning','ol']]],['Tools',[['Operational Toolbox','tools-toolbox',{rep:'Also in Surge'}],['Survey Designer','survey',{ext:1}]]],['Resources',[['Montandon – the Global Crisis Data Bank','montandon'],['Catalogue of Surge Services','res-surge',{rep:'Also in Surge'}],['PER Catalogue of Resources','res-per',{rep:'Also in PER'}],['GO Resources','go-resources']]],['GO Blog',[['GO Blog','blog',{ext:1}]]]]}
 ]},
 {zone:'Top bar',cols:[
  {t:'Search',sp:2,icon:'search',go:'search',groups:[[null,[['Search results','search']]]]},
  {t:'Language',sp:1,icon:'lang',go:'language',groups:[[null,[['English','language',{dd:1}],['Français','language',{dd:1}],['Español','language',{dd:1}],['Arabic','language',{dd:1}]]]]},
  {t:'Login / Register',sp:2,icon:'login',go:'login',groups:[[null,[['Login','login'],['Register','register']]]]},
  {t:'My Account',sp:2,icon:'user',go:'my-account',lock:1,groups:[[null,[['Account','my-account',{dd:1}],['Logout',null,{dd:1,plain:1}]]]]},
  {t:'Create a Report',sp:2,icon:'plus',go:'form-field',lock:1,groups:[[null,[['New Field Report','form-field',{act:1}],['New DREF Application','form-dref',{act:1}],['New Flash Update','form-flash',{act:1,ifrc:1}]]]]}
 ]},
 {zone:'Footer',cols:[
  {t:'Footer',sp:2,icon:'doc',go:'terms',groups:[['Policies',[['Terms and Conditions','terms'],['Cookie Policy','cookie']]],['Helpful links',[['Open Source Code','footer-ext',{ext:1}],['API Documentation','footer-ext',{ext:1}],['GO Wiki','footer-ext',{ext:1}]]]]}
 ]}
];
