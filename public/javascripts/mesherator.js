(function(exports, jQuery) {
  var Mesherator;
  var __bind = function(fn, context) {
    return function() {
      return fn.apply(context, arguments);
    };
  };

  Mesherator = function() {
    this.scene  = new THREE.Scene();
    this.camera = new THREE.CombinedCamera(window.innerWidth,
                                           window.innerHeight,
                                           70, 0.1, 1000000, -500, 1000);

    this.renderer = new THREE.WebGLRenderer();
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.camera.up = new THREE.Vector3(0, 0, 1);
  };

  Mesherator.prototype.setup = function() {
    $('#mesherator').append(this.renderer.domElement);
    this.loadPointSet('small');
  };

  Mesherator.prototype.loadPointSet = function(pointSet) {
    this.generateRandomPointSet();
    this.showCurrentPointSet();
    this.triangulateCurrentPointSet('slow');
  };

  Mesherator.prototype.generateRandomPointSet = function(numberOfPoints) {
    var pointIndex, point, x, y, z;
    numberOfPoints = numberOfPoints || 5000;
    
    this.points = [];
    this.vectors = [];

    for (pointIndex = 0; pointIndex < numberOfPoints; pointIndex++) {
      x = Math.random() * window.innerWidth;
      y = Math.random() * window.innerHeight;
      z = Math.random() * 10;

      this.points.push({ x: x, y: y, z: z });
      this.vectors.push(new THREE.Vector3(x, y, z));
    }
  };

  Mesherator.prototype.showCurrentPointSet = function() {
    var pointIndex, point;
    var material, particleSystem, boundingBox;

    var geometry = new THREE.Geometry();
    geometry.vertices = this.vectors;

    material = new THREE.ParticleBasicMaterial({
      color: 0xff0f00,
      sizeAttenuation: false,
      size: 2,
      transparent: false
    });

    particleSystem = new THREE.ParticleSystem(geometry, material);
    geometry.computeBoundingBox();
    this.currentBoundingSphere = geometry.boundingBox.getBoundingSphere();
    this.scene.add(particleSystem);

    this.animate();
  };

  Mesherator.prototype.triangulateCurrentPointSet = function(slowOrFast) {
    var callback = __bind(this.showTriangulation, this);
    if (slowOrFast == 'slow') {
      jQuery.post('/triangulate/slow', { points: this.points }).success(callback);
    } else {
      jQuery.post('/triangulate/fast', { points: this.points }).success(callback);
    }
  };

  Mesherator.prototype.render = function() {
    var camera = this.camera,
        scene = this.scene,
        renderer = this.renderer;
    
    var timer = Date.now() * 0.0001;
    var rotation = this.currentBoundingSphere.radius * 2;

    camera.position.x = (Math.cos(timer) * rotation / 5) + this.currentBoundingSphere.center.x;
    camera.position.y = (Math.sin(timer) * rotation / 5) + this.currentBoundingSphere.center.y;
    camera.position.z = this.currentBoundingSphere.radius / 5;
    camera.lookAt(this.currentBoundingSphere.center);

    // camera.position.x = this.currentBoundingSphere.center.x;
    // camera.position.y = this.currentBoundingSphere.center.y;
    // camera.position.z = this.currentBoundingSphere.radius;
    // camera.lookAt(this.currentBoundingSphere.center);
    // console.log(this.currentBoundingSphere.center);

    renderer.render(this.scene, this.camera);
  };

  Mesherator.prototype.animate = function() {
    requestAnimationFrame(__bind(this.animate, this));
    this.render();
  };

  Mesherator.prototype.showTriangulation = function(triangles) {
    var geometry = new THREE.Geometry();
    var triangleIndex, triangle, v0, v1, v2, mesh;

    for (triangleIndex = 0; triangleIndex < triangles.length; triangleIndex++) {
      triangle = triangles[triangleIndex];
      v0 = this._jsonPointToVector3(triangle[0]);
      v1 = this._jsonPointToVector3(triangle[1]);
      v2 = this._jsonPointToVector3(triangle[2]);

      geometry.vertices.push(v0);
      geometry.vertices.push(v1);
      geometry.vertices.push(v2);

      geometry.faces.push(new THREE.Face3(triangleIndex * 3, triangleIndex * 3 + 1, triangleIndex * 3 + 2));
    }

    mesh = new THREE.Mesh(geometry, new THREE.MeshBasicMaterial({
      color: 0x00ff00,
      wireframe: true,
      wireframeLineWidth: 1.0
    }));

    this.scene.add(mesh);
  };

  Mesherator.prototype._jsonPointToVector3 = function(point) {
    return new THREE.Vector3(point.x, point.y, point.z);
  };
  
  exports.Mesherator = Mesherator;
})(window, jQuery);

var app;

$(document).ready(function() {
  app = new Mesherator();
  app.setup();
});
