// Define the area of interest (AOI)
var aoi = ee.Geometry.Polygon([
    [
      [6.837094123822363, 52.23018090803254],
      [6.881897743207128, 52.23018090803254],
      [6.881897743207128, 52.253095730719515],
      [6.837094123822363, 52.253095730719515],
      [6.837094123822363, 52.23018090803254]
    ]
  ]);
  
  // Define the years and seasons
  var startYear = 2021;
  var endYear = 2024;
  var seasons = [
    {name: 'Winter', startMonth: 12, endMonth: 2},
    {name: 'Spring', startMonth: 3, endMonth: 5},
    {name: 'Summer', startMonth: 6, endMonth: 8},
    {name: 'Fall', startMonth: 9, endMonth: 11}
  ];
  
  // Prepare the collection and filter for each season and year
  var images = [];
  
  for (var year = startYear; year <= endYear; year++) {
    for (var i = 0; i < seasons.length; i++) {
      var season = seasons[i];
      var startDate = ee.Date.fromYMD(year, season.startMonth, 1);
      var endDate = season.endMonth === 2 ? ee.Date.fromYMD(year + 1, season.endMonth, 28) : ee.Date.fromYMD(year, season.endMonth, 30);
  
      var landsat = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2')
        .filterBounds(aoi)
        .filterDate(startDate, endDate)
        .filter(ee.Filter.lt('CLOUD_COVER', 10))
        .map(function(image) {
          var qa = image.select('QA_PIXEL');
          var cloudShadowBitMask = (1 << 3);
          var cloudsBitMask = (1 << 5);
          var mask = qa.bitwiseAnd(cloudShadowBitMask).eq(0)
            .and(qa.bitwiseAnd(cloudsBitMask).eq(0));
          image = image.updateMask(mask).clip(aoi);
  
          var thermal = image.select('ST_B10');
          var lst = thermal.multiply(0.00341802).add(149.0).subtract(273.15).rename('LST');
          return image.addBands(lst);
        });
  
      var composite = landsat.select('LST').mean().set({
        'year': year,
        'season': season.name
      });
  
      images.push(composite);
    }
  }
  
  // Merge all seasonal composites into a single image collection
  var composites = ee.ImageCollection(images);
  
  // Create a composite image for the entire period
  var overallComposite = composites.mean();
  
  // Display the results
  Map.centerObject(aoi, 12);
  Map.addLayer(aoi, {color: 'red'}, 'AOI');
  
  for (var j = 0; j < images.length; j++) {
    var image = images[j];
    Map.addLayer(image, {min: -10, max: 40, palette: ['blue', 'white', 'red']}, image.get('season').getInfo() + ' ' + image.get('year').getInfo());
  }
  
  Map.addLayer(overallComposite, {min: -10, max: 40, palette: ['blue', 'white', 'red']}, 'Overall Composite');
  