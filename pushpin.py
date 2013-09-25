# ToDo:
# fire eagle
# http://fireeagle.yahoo.net/developer/documentation/python_walkthru
# http://fireeagle.yahoo.net/developer/explorer/0.1/within#upcoming_venue_id

# google maps & picasa
# http://code.google.com/p/geopy/
# http://code.google.com/p/pymaps/
# http://www.developer.com/db/article.php/3621981/Performing-HTTP-Geocoding-with-the-Google-Maps-API.htm
# http://code.google.com/apis/maps/documentation/geocoding/#ReverseGeocoding

# foursquare
# http://foursquare.com/

# misc
# http://geoapi.blogspot.com/2009/11/introducing-geoapicom-from-mixer-labs.html

# Done:
# flickr
# youtube
# twitter

from __future__ import print_function
import urllib2
import webbrowser
import sys

class Map(object):
  base_url = None

  def __init__(self, latitude=0.0, longitude=0.0, radius=5):
    self.options = { 
      "latitude":latitude,      # latitude (degrees)
      "longitude":longitude,    # longitude (degree)
      "radius":radius }         # radius (kilometers)

    self.show_results()
  
  def show_results(self):
    args = (self.options["latitude"], 
      self.options["longitude"], self.options["radius"])
    webbrowser.open_new_tab(self.base_url % args)
  
  
class TwitterPin(Map):
  base_url = "http://search.twitter.com/"
  base_url += "search.atom?geocode=%.6f,%.6f,%dkm"
  

class FlickrPin(TwitterPin):
  base_url = "http://www4.wiwiss.fu-berlin.de/"
  base_url += "flickrwrappr/location/%.6f/%.6f/%d"
    
  def __init__(self, **kwargs):
    kwargs["radius"] *= 1000    # radius is in meters instead of km
    TwitterPin.__init__(self, **kwargs)

    
class YouTubePin(TwitterPin):
  base_url = "http://gdata.youtube.com/feeds/api/videos"
  base_url += "?location=%.5f,%.5f&location-radius=%dkm"

  
def interactive():
  coords = {}
  lat = "Enter a latitude (in degrees): "
  long = "Enter a longitude (in degrees): "
  rad = "Enter a radius (in kilometers): "
  while True:
    try:
      try:
        if not coords.get('latitude'): coords['latitude'] = float(raw_input(lat))
        if not coords.get('longitude'): coords['longitude'] = float(raw_input(long))
        if not coords.get('radius'): coords['radius'] = float(raw_input(rad))
      except NameError:
        if not coords.get('latitude'): coords['latitude'] = float(input(lat))
        if not coords.get('longitude'): coords['longitude'] = float(input(long))
        if not coords.get('radius'): coords['radius'] = float(input(rad))
    except ValueError:
      print("Please enter only numbers")
    else:
      break

  return coords

  
def process_cmd_opts(argv):
  if len(argv) == 1:
    return interactive()

  if '-h' in argv:
    print("usage: %s latitude longitude radius" % argv[0])
    print("lat and long are in degrees, radius is in kilometers")
    return
    
  coords = {}
  
  try:
    coords["latitude"] = float(argv[1])
    coords["longitude"] = float(argv[2])
    coords["radius"] = float(argv[3])
  except (ValueError, IndexError):
    return interactive()
  else:
    return coords  
  
  
def main(argv):
  coords = process_cmd_opts(argv)
  if not coords: 
    return
  
  TwitterPin(**coords)
  YouTubePin(**coords)
  FlickrPin(**coords)


if __name__ == "__main__":
  try:
    main(sys.argv)
  except KeyboardInterrupt:
    pass
