(function () {
    'use strict';

    const container = document.getElementById('gizmo-container');
    const appElement = document.getElementById('app');
    const modeBadge = document.getElementById('mode-badge');
    const modeLabel = document.getElementById('mode-label');
    const coordX = document.getElementById('coord-x');
    const coordY = document.getElementById('coord-y');
    const coordZ = document.getElementById('coord-z');
    const coordHeading = document.getElementById('coord-heading');

    let isGizmoActive = false;
    let currentEntityHandle = null;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(55, window.innerWidth / window.innerHeight, 0.1, 1000);
    camera.position.set(0, 0, 10);
    camera.rotation.order = "YZX";

    const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true, powerPreference: 'high-performance' });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.setClearColor(0x000000, 0);
    container.appendChild(renderer.domElement);

    const dummy = new THREE.Object3D();
    scene.add(dummy);

    const controls = new THREE.TransformControls(camera, renderer.domElement);
    controls.size = 0.75;
    controls.space = 'local';
    scene.add(controls);
    controls.attach(dummy);

    const radToDeg = THREE.MathUtils.radToDeg;
    const degToRad = THREE.MathUtils.degToRad;

    const ROTATION_ORDERS = {
        0: "YZX",
        1: "ZYX",
        2: "YXZ",
        3: "XYZ",
        4: "ZXY",
        5: "XZY"
    };

    let currentLocale = 'tr';
    const LOCALES = {
        en: {
            HUD_LIVE_COORDS: "LIVE COORDINATES",
            HUD_MOVE_MODE: "MOVE MODE",
            HUD_ROTATE_MODE: "ROTATE MODE"
        },
        tr: {
            HUD_LIVE_COORDS: "CANLI KOORDİNATLAR",
            HUD_MOVE_MODE: "TAŞIMA MODU",
            HUD_ROTATE_MODE: "DÖNDÜRME MODU"
        },
        de: {
            HUD_LIVE_COORDS: "LIVE-KOORDINATEN",
            HUD_MOVE_MODE: "BEWEGUNGSMODUS",
            HUD_ROTATE_MODE: "ROTATIONSMODUS"
        },
        fr: {
            HUD_LIVE_COORDS: "COORDONNÉES EN DIRECT",
            HUD_MOVE_MODE: "MODE DÉPLACEMENT",
            HUD_ROTATE_MODE: "MODE ROTATION"
        }
    };

    function _t(key) {
        const dict = LOCALES[currentLocale] || LOCALES.en || LOCALES.tr;
        return (dict && dict[key]) || key;
    }

    function applyLocale() {
        const coordsTitle = document.querySelector('.coords-title span');
        if (coordsTitle) coordsTitle.textContent = _t('HUD_LIVE_COORDS');
        updateModeHUD(controls ? controls.getMode() : 'translate');
    }

    function getResourceName() {
        if (typeof window.GetParentResourceName === 'function') {
            return window.GetParentResourceName();
        }
        return 'cagan-animpos';
    }

    function postNui(event, data) {
        return fetch(`https://${getResourceName()}/${event}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data || {})
        }).catch(() => {});
    }

    function updateCoordinateHUD(pos, rot) {
        if (pos) {
            if (coordX) coordX.textContent = Number(pos.x).toFixed(2);
            if (coordY) coordY.textContent = Number(pos.y).toFixed(2);
            if (coordZ) coordZ.textContent = Number(pos.z).toFixed(2);
        }
        if (rot) {
            const h = rot.z !== undefined ? rot.z : (rot.y !== undefined ? rot.y : 0);
            if (coordHeading) coordHeading.textContent = `${Math.round(h)}°`;
        }
    }

    function updateModeHUD(mode) {
        if (!modeBadge || !modeLabel) return;
        if (mode === 'rotate') {
            modeBadge.className = 'mode-badge mode-rotate';
            modeLabel.textContent = _t('HUD_ROTATE_MODE');
        } else {
            modeBadge.className = 'mode-badge mode-translate';
            modeLabel.textContent = _t('HUD_MOVE_MODE');
        }
    }

    controls.addEventListener('objectChange', function () {
        if (!isGizmoActive || currentEntityHandle == null) return;

        const redmPos = {
            x: dummy.position.x,
            y: -dummy.position.z,
            z: dummy.position.y
        };

        const redmRot = {
            x: radToDeg(dummy.rotation.x),
            y: radToDeg(-dummy.rotation.z),
            z: radToDeg(dummy.rotation.y)
        };

        postNui('gizmoMoveEntity', {
            handle: currentEntityHandle,
            position: redmPos,
            rotation: redmRot
        });

        updateCoordinateHUD(redmPos, redmRot);
    });

    function renderLoop() {
        requestAnimationFrame(renderLoop);
        if (isGizmoActive) {
            renderer.render(scene, camera);
        }
    }
    renderLoop();

    window.addEventListener('resize', function () {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
    });

    window.addEventListener('keyup', function (e) {
        if (!isGizmoActive) return;
        if (e.code === 'KeyR') {
            const currentMode = controls.getMode();
            const newMode = (currentMode === 'translate') ? 'rotate' : 'translate';
            controls.setMode(newMode);
            updateModeHUD(newMode);
            postNui('gizmoSetPreferredMode', { uiMode: (newMode === 'rotate') });
        }
    });

    window.addEventListener('message', function (event) {
        const item = event.data;
        if (!item || !item.action) return;

        switch (item.action) {
            case 'setGizmoEntity': {
                if (!item.data || item.data.handle == null) {
                    isGizmoActive = false;
                    currentEntityHandle = null;
                    if (appElement) appElement.style.display = 'none';
                    controls.detach();
                    return;
                }

                const data = item.data;
                currentEntityHandle = data.handle;
                if (data.locale) currentLocale = data.locale;
                if (data.locales) {
                    LOCALES[currentLocale] = Object.assign({}, LOCALES[currentLocale] || {}, data.locales);
                }
                applyLocale();

                isGizmoActive = true;
                if (appElement) appElement.style.display = 'block';

                controls.attach(dummy);

                dummy.position.set(data.position.x, data.position.z, -data.position.y);

                const order = ROTATION_ORDERS[data.rotationOrder ?? 2] || "YXZ";
                dummy.rotation.order = order;
                dummy.rotation.set(
                    degToRad(data.rotation.x),
                    degToRad(data.rotation.z),
                    degToRad(data.rotation.y)
                );

                updateCoordinateHUD(data.position, data.rotation);
                break;
            }

            case 'setGizmoCamera': {
                if (!item.data) return;
                const camData = item.data;
                camera.position.set(camData.position.x, camData.position.z, -camData.position.y);
                camera.rotation.order = "YZX";

                const n = (a, i) => (a > 0 && a < 90) ? i : ((a > -180 && a < -90) || a > 0 ? -i : i);
                if (camData.rotation) {
                    camera.rotation.set(
                        degToRad(camData.rotation.x),
                        degToRad(n(camData.rotation.x, camData.rotation.z)),
                        degToRad(camData.rotation.y)
                    );
                }
                camera.updateProjectionMatrix();
                break;
            }

            case 'gizmoMode': {
                const isRotate = !!(item.data && item.data.uiMode);
                const mode = isRotate ? 'rotate' : 'translate';
                controls.setMode(mode);
                updateModeHUD(mode);
                break;
            }
        }
    });

    window.addEventListener('DOMContentLoaded', function () {
        postNui('uiReady', {});
        postNui('gizmoSetPreferredMode', { uiMode: false });
    });
})();
