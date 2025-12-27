/**
 * Voice2Print 3D Model Catalogue
 * Three.js powered viewer with STL rendering and SCAD code display
 */

class ModelCatalogue {
    constructor() {
        this.models = [];
        this.folders = {};
        this.currentFolder = 'all';
        this.currentView = 'grid';
        this.currentFilter = 'all';  // 'all', 'stl', 'scad'
        this.currentSort = 'type-desc';  // Default: STL files first
        
        // Three.js main viewer
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        this.currentMesh = null;
        this.wireframeMode = false;
        this.autoRotate = false;
        this.currentModel = null;  // Track current model for download
        
        // Card preview system - use single offscreen renderer
        this.previewRenderer = null;
        this.previewScene = null;
        this.previewCamera = null;
        this.stlLoader = null;
        this.stlCache = new Map();
        
        // Intersection observer for lazy loading
        this.observer = null;
        
        // DOM Elements
        this.gallery = document.getElementById('gallery');
        this.folderList = document.getElementById('folder-list');
        this.modal = document.getElementById('viewer-modal');
        this.threeContainer = document.getElementById('three-container');
        
        // Color palette for models - saturated colors
        this.colorPalette = [
            0xe63946, // Red
            0xf4a261, // Orange
            0xe9c46a, // Yellow
            0x2a9d8f, // Teal
            0x264653, // Dark blue
            0x8338ec, // Purple
            0xff006e, // Pink
            0x06d6a0, // Mint
            0x118ab2, // Blue
            0x073b4c, // Navy
            0xef476f, // Coral
            0xffd166, // Gold
            0x06d6a0, // Green
            0x7209b7, // Violet
            0x3a0ca3, // Indigo
            0xf72585, // Magenta
        ];
        
        this.init();
    }
    
    getRandomColor(seed) {
        // Use seed for consistent color per model
        const index = Math.abs(this.hashCode(seed)) % this.colorPalette.length;
        return this.colorPalette[index];
    }
    
    hashCode(str) {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash;
        }
        return hash;
    }
    
    async init() {
        // Initialize STL loader
        this.stlLoader = new THREE.STLLoader();
        
        // Initialize preview renderer (single shared instance)
        this.initPreviewRenderer();
        
        await this.loadCatalogue();
        this.setupEventListeners();
        this.renderFolders();
        this.renderGallery();
        this.initThreeJS();
    }
    
    initPreviewRenderer() {
        // Single offscreen renderer for generating preview images
        this.previewRenderer = new THREE.WebGLRenderer({ 
            antialias: true,
            alpha: true,
            preserveDrawingBuffer: true
        });
        this.previewRenderer.setSize(200, 140);
        this.previewRenderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        this.previewRenderer.shadowMap.enabled = true;
        this.previewRenderer.shadowMap.type = THREE.PCFSoftShadowMap;
        
        // Preview scene
        this.previewScene = new THREE.Scene();
        this.previewScene.background = new THREE.Color(0x1a1a1e);
        
        // Preview camera
        this.previewCamera = new THREE.PerspectiveCamera(45, 200/140, 0.1, 1000);
        
        // Enhanced preview lighting for texture visibility
        const ambient = new THREE.AmbientLight(0xffffff, 0.3);
        this.previewScene.add(ambient);
        
        // Key light - main light with shadows
        const keyLight = new THREE.DirectionalLight(0xffffff, 1.0);
        keyLight.position.set(2, 3, 2);
        keyLight.castShadow = true;
        this.previewScene.add(keyLight);
        
        // Fill light - softer, from opposite side
        const fillLight = new THREE.DirectionalLight(0xffffff, 0.4);
        fillLight.position.set(-2, 1, -1);
        this.previewScene.add(fillLight);
        
        // Rim light - for edge definition
        const rimLight = new THREE.DirectionalLight(0xffffff, 0.3);
        rimLight.position.set(0, -1, -2);
        this.previewScene.add(rimLight);
    }
    
    async loadCatalogue() {
        try {
            const response = await fetch('models.json');
            const data = await response.json();
            this.models = data.models;
            this.folders = data.folders;
            
            // Update stats
            document.getElementById('model-count').textContent = this.models.length;
            document.getElementById('folder-count').textContent = Object.keys(this.folders).length;
        } catch (error) {
            console.error('Failed to load catalogue:', error);
            this.gallery.innerHTML = `
                <div style="grid-column: 1/-1; text-align: center; padding: 3rem; color: var(--text-muted);">
                    <p>Failed to load model catalogue.</p>
                    <p style="font-size: 0.8rem; margin-top: 0.5rem;">Run <code>python generate_catalogue.py</code> to generate it.</p>
                </div>
            `;
        }
    }
    
    setupEventListeners() {
        // View toggle
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                document.querySelectorAll('.view-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                this.currentView = btn.dataset.view;
                this.gallery.className = `gallery ${this.currentView}-view`;
            });
        });
        
        // Filter toggles
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                this.currentFilter = btn.dataset.filter;
                this.renderGallery();
            });
        });
        
        // Sort dropdown
        document.getElementById('sort-select').addEventListener('change', (e) => {
            this.currentSort = e.target.value;
            this.renderGallery();
        });
        
        // Modal close
        document.getElementById('close-modal').addEventListener('click', () => this.closeModal());
        document.querySelector('.modal-backdrop').addEventListener('click', () => this.closeModal());
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') this.closeModal();
        });
        
        // Viewer controls
        document.getElementById('reset-camera').addEventListener('click', () => this.resetCamera());
        document.getElementById('toggle-wireframe').addEventListener('click', (e) => this.toggleWireframe(e.currentTarget));
        document.getElementById('toggle-autorotate').addEventListener('click', (e) => this.toggleAutoRotate(e.currentTarget));
        document.getElementById('copy-code').addEventListener('click', () => this.copyCode());
        document.getElementById('download-file').addEventListener('click', () => this.downloadCurrentFile());
        
        // Window resize
        window.addEventListener('resize', () => this.onWindowResize());
    }
    
    renderFolders() {
        const totalCount = this.models.length;
        
        let html = `
            <li class="folder-item active" data-folder="all">
                <span class="folder-name">
                    <svg class="folder-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/>
                    </svg>
                    All Models
                </span>
                <span class="folder-count">${totalCount}</span>
            </li>
        `;
        
        for (const [path, info] of Object.entries(this.folders)) {
            html += `
                <li class="folder-item" data-folder="${path}">
                    <span class="folder-name">
                        <svg class="folder-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/>
                        </svg>
                        ${info.name}
                    </span>
                    <span class="folder-count">${info.count}</span>
                </li>
            `;
        }
        
        this.folderList.innerHTML = html;
        
        this.folderList.querySelectorAll('.folder-item').forEach(item => {
            item.addEventListener('click', () => {
                document.querySelectorAll('.folder-item').forEach(i => i.classList.remove('active'));
                item.classList.add('active');
                this.currentFolder = item.dataset.folder;
                document.getElementById('current-folder').textContent = 
                    this.currentFolder === 'all' ? 'All Models' : this.folders[this.currentFolder]?.name || this.currentFolder;
                this.renderGallery();
            });
        });
    }
    
    renderGallery() {
        // Disconnect old observer
        if (this.observer) {
            this.observer.disconnect();
        }
        
        // Apply folder filter
        let filteredModels = this.currentFolder === 'all' 
            ? [...this.models]
            : this.models.filter(m => m.folder === this.currentFolder);
        
        // Apply type filter
        if (this.currentFilter !== 'all') {
            filteredModels = filteredModels.filter(m => m.type === this.currentFilter);
        }
        
        // Apply sorting
        filteredModels = this.sortModels(filteredModels);
        
        // Update result count
        document.getElementById('result-count').textContent = `(${filteredModels.length} items)`;
        
        if (filteredModels.length === 0) {
            this.gallery.innerHTML = `
                <div style="grid-column: 1/-1; text-align: center; padding: 3rem; color: var(--text-muted);">
                    No models match the current filters.
                </div>
            `;
            return;
        }
        
        const formatSize = (bytes) => {
            if (bytes < 1024) return bytes + ' B';
            if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
            return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
        };
        
        this.gallery.innerHTML = filteredModels.map(model => `
            <article class="model-card" data-id="${model.id}" data-type="${model.type}" data-path="${model.path}">
                <div class="card-preview" id="preview-${model.id}">
                    ${model.type === 'stl' 
                        ? `<div class="preview-placeholder">
                               <svg class="card-preview-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                   <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                               </svg>
                           </div>`
                        : `<svg class="card-preview-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                               <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                               <path d="M14 2v6h6M16 13H8M16 17H8M10 9H8"/>
                           </svg>`
                    }
                </div>
                <div class="card-content">
                    <h3 class="card-title" title="${model.name}">${model.name}</h3>
                    <div class="card-meta">
                        <span class="card-tag ${model.type}">${model.type.toUpperCase()}</span>
                        <span class="card-size">${formatSize(model.size)}</span>
                    </div>
                </div>
            </article>
        `).join('');
        
        // Add click handlers
        this.gallery.querySelectorAll('.model-card').forEach(card => {
            card.addEventListener('click', () => {
                const model = this.models.find(m => m.id === card.dataset.id);
                if (model) this.openViewer(model);
            });
        });
        
        // Set up lazy loading for STL previews
        this.setupLazyLoading(filteredModels.filter(m => m.type === 'stl'));
    }
    
    sortModels(models) {
        const [field, direction] = this.currentSort.split('-');
        const modifier = direction === 'asc' ? 1 : -1;
        
        return models.sort((a, b) => {
            let comparison = 0;
            
            switch (field) {
                case 'name':
                    comparison = a.name.localeCompare(b.name);
                    break;
                case 'date':
                    comparison = new Date(a.modified) - new Date(b.modified);
                    break;
                case 'type':
                    comparison = a.type.localeCompare(b.type);
                    break;
                default:
                    comparison = 0;
            }
            
            return comparison * modifier;
        });
    }
    
    setupLazyLoading(stlModels) {
        // Create intersection observer for lazy loading previews
        this.observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const card = entry.target;
                    const modelId = card.dataset.id;
                    const model = stlModels.find(m => m.id === modelId);
                    if (model) {
                        this.loadPreviewImage(model);
                        this.observer.unobserve(card);
                    }
                }
            });
        }, {
            rootMargin: '100px',
            threshold: 0.1
        });
        
        // Observe all STL cards
        this.gallery.querySelectorAll('.model-card[data-type="stl"]').forEach(card => {
            this.observer.observe(card);
        });
    }
    
    async loadPreviewImage(model) {
        const container = document.getElementById(`preview-${model.id}`);
        if (!container) return;
        
        try {
            // Load STL geometry
            const geometry = await this.loadSTL(model.path);
            
            // Center geometry
            geometry.computeBoundingBox();
            const center = new THREE.Vector3();
            geometry.boundingBox.getCenter(center);
            geometry.translate(-center.x, -center.y, -center.z);
            
            // Get size for camera positioning
            const size = new THREE.Vector3();
            geometry.boundingBox.getSize(size);
            const maxDim = Math.max(size.x, size.y, size.z);
            
            // Create material with random saturated color, matte finish
            const color = this.getRandomColor(model.id);
            const material = new THREE.MeshStandardMaterial({
                color: color,
                metalness: 0.0,
                roughness: 0.85,
                flatShading: false,
            });
            
            const mesh = new THREE.Mesh(geometry, material);
            mesh.castShadow = true;
            mesh.receiveShadow = true;
            
            // Add mesh to preview scene temporarily
            this.previewScene.add(mesh);
            
            // Position camera
            const distance = maxDim * 1.8;
            this.previewCamera.position.set(distance * 0.7, distance * 0.5, distance * 0.7);
            this.previewCamera.lookAt(0, 0, 0);
            
            // Render to get image
            this.previewRenderer.render(this.previewScene, this.previewCamera);
            
            // Get image data
            const imageData = this.previewRenderer.domElement.toDataURL('image/png');
            
            // Remove mesh from scene
            this.previewScene.remove(mesh);
            geometry.dispose();
            material.dispose();
            
            // Update container with static image
            container.innerHTML = `<img src="${imageData}" alt="${model.name}" class="preview-image"/>`;
            
        } catch (error) {
            console.warn(`Failed to load preview for ${model.path}:`, error.message);
            // Show fallback icon (keep the placeholder)
            container.innerHTML = `
                <svg class="card-preview-icon error" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                    <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                </svg>
            `;
        }
    }
    
    // Three.js Main Viewer Setup
    initThreeJS() {
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x0d0d0f);
        
        this.camera = new THREE.PerspectiveCamera(
            45,
            this.threeContainer.clientWidth / this.threeContainer.clientHeight,
            0.1,
            2000
        );
        this.camera.position.set(100, 100, 100);
        
        this.renderer = new THREE.WebGLRenderer({ 
            antialias: true,
            alpha: true
        });
        this.renderer.setSize(this.threeContainer.clientWidth, this.threeContainer.clientHeight);
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        this.threeContainer.appendChild(this.renderer.domElement);
        
        this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
        this.controls.enableDamping = true;
        this.controls.dampingFactor = 0.05;
        this.controls.minDistance = 10;
        this.controls.maxDistance = 500;
        
        this.setupLighting();
        this.setupGround();
        this.animate();
    }
    
    setupLighting() {
        // Lower ambient for more contrast
        const ambient = new THREE.AmbientLight(0xffffff, 0.25);
        this.scene.add(ambient);
        
        // Key light - main directional with strong shadows
        const mainLight = new THREE.DirectionalLight(0xffffff, 1.2);
        mainLight.position.set(50, 100, 50);
        mainLight.castShadow = true;
        mainLight.shadow.mapSize.width = 2048;
        mainLight.shadow.mapSize.height = 2048;
        mainLight.shadow.camera.near = 0.5;
        mainLight.shadow.camera.far = 500;
        mainLight.shadow.camera.left = -100;
        mainLight.shadow.camera.right = 100;
        mainLight.shadow.camera.top = 100;
        mainLight.shadow.camera.bottom = -100;
        mainLight.shadow.bias = -0.0001;
        this.scene.add(mainLight);
        
        // Fill light - softer, opposite side
        const fillLight = new THREE.DirectionalLight(0xffffff, 0.4);
        fillLight.position.set(-80, 40, -30);
        this.scene.add(fillLight);
        
        // Top light - emphasizes surface detail
        const topLight = new THREE.DirectionalLight(0xffffff, 0.3);
        topLight.position.set(0, 150, 0);
        this.scene.add(topLight);
        
        // Rim light - edge definition
        const rimLight = new THREE.DirectionalLight(0xffffff, 0.2);
        rimLight.position.set(-30, 20, -80);
        this.scene.add(rimLight);
    }
    
    setupGround() {
        const groundGeometry = new THREE.PlaneGeometry(500, 500);
        const groundMaterial = new THREE.ShadowMaterial({ opacity: 0.3 });
        this.ground = new THREE.Mesh(groundGeometry, groundMaterial);
        this.ground.rotation.x = -Math.PI / 2;
        this.ground.position.y = -50;
        this.ground.receiveShadow = true;
        this.scene.add(this.ground);
        
        this.grid = new THREE.GridHelper(200, 20, 0x333338, 0x222226);
        this.grid.position.y = -49.9;
        this.scene.add(this.grid);
    }
    
    animate() {
        requestAnimationFrame(() => this.animate());
        
        if (this.autoRotate && this.currentMesh) {
            this.currentMesh.rotation.y += 0.005;
        }
        
        this.controls.update();
        this.renderer.render(this.scene, this.camera);
    }
    
    async loadSTL(path) {
        // Check cache first
        if (this.stlCache.has(path)) {
            return this.stlCache.get(path).clone();
        }
        
        return new Promise((resolve, reject) => {
            this.stlLoader.load(
                path,
                (geometry) => {
                    // Cache the geometry
                    this.stlCache.set(path, geometry.clone());
                    resolve(geometry);
                },
                undefined,
                (error) => reject(error)
            );
        });
    }
    
    async openViewer(model) {
        this.modal.classList.add('active');
        this.currentModel = model;  // Store for download
        
        // Update download button text
        const downloadBtn = document.getElementById('download-file');
        downloadBtn.querySelector('span').textContent = `Download .${model.type}`;
        
        document.getElementById('viewer-title').textContent = model.name;
        document.getElementById('viewer-folder').textContent = this.folders[model.folder]?.name || 'Main Collection';
        document.getElementById('viewer-files').textContent = `.${model.type}`;
        
        if (model.type === 'stl') {
            await this.loadSTLInViewer(model.path);
            document.getElementById('code-filename').textContent = 'STL Binary File';
            document.getElementById('code-display').textContent = '// STL files are binary 3D mesh data\n// No source code available\n\n// To view the OpenSCAD source,\n// look for a matching .scad file';
        } else if (model.type === 'scad') {
            // Try to find matching STL file
            const stlPath = model.path.replace('.scad', '.stl');
            const matchingStl = this.models.find(m => m.path === stlPath);
            
            if (matchingStl) {
                // Load the matching STL for 3D preview
                await this.loadSTLInViewer(matchingStl.path);
            } else {
                // No matching STL - show render option
                this.showScadOnlyMessage(model.path);
            }
            
            await this.loadScadCode(model.path);
        }
        
        this.onWindowResize();
    }
    
    async loadSTLInViewer(path) {
        // Hide any SCAD overlay
        this.hideScadOverlay();
        
        try {
            if (this.currentMesh) {
                this.scene.remove(this.currentMesh);
                this.currentMesh.geometry.dispose();
                this.currentMesh.material.dispose();
            }
            
            const geometry = await this.loadSTL(path);
            
            geometry.computeBoundingBox();
            const center = new THREE.Vector3();
            geometry.boundingBox.getCenter(center);
            geometry.translate(-center.x, -center.y, -center.z);
            
            const size = new THREE.Vector3();
            geometry.boundingBox.getSize(size);
            const maxDim = Math.max(size.x, size.y, size.z);
            
            // Use model's random color, matte finish for texture visibility
            const color = this.getRandomColor(this.currentModel?.id || path);
            const material = new THREE.MeshStandardMaterial({
                color: color,
                metalness: 0.0,
                roughness: 0.85,
                flatShading: false,
            });
            
            this.currentMesh = new THREE.Mesh(geometry, material);
            this.currentMesh.castShadow = true;
            this.currentMesh.receiveShadow = true;
            this.scene.add(this.currentMesh);
            
            const bbox = geometry.boundingBox;
            this.ground.position.y = bbox.min.y - center.y - 1;
            this.grid.position.y = this.ground.position.y + 0.1;
            
            const cameraDistance = maxDim * 2;
            this.camera.position.set(cameraDistance, cameraDistance * 0.7, cameraDistance);
            this.controls.target.set(0, 0, 0);
            this.controls.update();
            
        } catch (error) {
            console.error('Failed to load STL:', error);
        }
    }
    
    showScadOnlyMessage(scadPath) {
        if (this.currentMesh) {
            this.scene.remove(this.currentMesh);
            this.currentMesh.geometry.dispose();
            this.currentMesh.material.dispose();
            this.currentMesh = null;
        }
        
        this.camera.position.set(100, 100, 100);
        this.controls.target.set(0, 0, 0);
        this.controls.update();
        
        // Show overlay message
        let overlay = this.threeContainer.querySelector('.scad-overlay');
        if (!overlay) {
            overlay = document.createElement('div');
            overlay.className = 'scad-overlay';
            this.threeContainer.appendChild(overlay);
        }
        
        overlay.innerHTML = `
            <div class="scad-message">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                    <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                    <path d="M14 2v6h6M16 13H8M16 17H8M10 9H8"/>
                </svg>
                <h3>OpenSCAD Source File</h3>
                <p>View the source code on the right panel.</p>
                <p class="hint">Download the .scad file to render in OpenSCAD.</p>
            </div>
        `;
        
        overlay.style.display = 'flex';
    }
    
    hideScadOverlay() {
        const overlay = this.threeContainer.querySelector('.scad-overlay');
        if (overlay) {
            overlay.style.display = 'none';
        }
    }
    
    async loadScadCode(path) {
        document.getElementById('code-filename').textContent = path.split('/').pop();
        try {
            const response = await fetch(path);
            const code = await response.text();
            document.getElementById('code-display').textContent = code;
        } catch (error) {
            document.getElementById('code-display').textContent = '// Failed to load source file';
        }
    }
    
    closeModal() {
        this.modal.classList.remove('active');
    }
    
    resetCamera() {
        if (this.currentMesh) {
            this.currentMesh.rotation.set(0, 0, 0);
        }
        
        const bbox = this.currentMesh?.geometry?.boundingBox;
        if (bbox) {
            const size = new THREE.Vector3();
            bbox.getSize(size);
            const maxDim = Math.max(size.x, size.y, size.z);
            const distance = maxDim * 2;
            
            this.camera.position.set(distance, distance * 0.7, distance);
            this.controls.target.set(0, 0, 0);
            this.controls.update();
        }
    }
    
    toggleWireframe(button) {
        this.wireframeMode = !this.wireframeMode;
        button.classList.toggle('active', this.wireframeMode);
        
        if (this.currentMesh) {
            this.currentMesh.material.wireframe = this.wireframeMode;
        }
    }
    
    toggleAutoRotate(button) {
        this.autoRotate = !this.autoRotate;
        button.classList.toggle('active', this.autoRotate);
    }
    
    async copyCode() {
        const code = document.getElementById('code-display').textContent;
        try {
            await navigator.clipboard.writeText(code);
            const btn = document.getElementById('copy-code');
            btn.style.background = 'var(--accent-copper)';
            setTimeout(() => btn.style.background = '', 1000);
        } catch (error) {
            console.error('Failed to copy:', error);
        }
    }
    
    async downloadCurrentFile() {
        if (!this.currentModel) return;
        
        const model = this.currentModel;
        const filename = model.path.split('/').pop();
        
        try {
            // Fetch the file
            const response = await fetch(model.path);
            const blob = await response.blob();
            
            // Create download link
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            
            // Visual feedback
            const btn = document.getElementById('download-file');
            const originalText = btn.querySelector('span').textContent;
            btn.querySelector('span').textContent = 'Downloaded!';
            setTimeout(() => {
                btn.querySelector('span').textContent = originalText;
            }, 1500);
            
        } catch (error) {
            console.error('Download failed:', error);
        }
    }
    
    onWindowResize() {
        if (!this.threeContainer || !this.camera || !this.renderer) return;
        
        const width = this.threeContainer.clientWidth;
        const height = this.threeContainer.clientHeight;
        
        this.camera.aspect = width / height;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(width, height);
    }
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    new ModelCatalogue();
});
