GeoEasy Step by Step
====================

::
	Warning: This training material does not extend to the use of the program in every 
	detail, further information can be found in other documentation files.

The installation kit contains a *demodata* directory. In this guide the data
files from *demodata* directory will be used.

Images in this tutorial are generated on an Ubuntu box. Window layouts on
different operating systems may look different.

After starting GeoEasy a small windows appears near to the upper left corner
of your monitor. It is the main window with a menu and a rotating Earth.
If the rotation stopped the software is busy

.. figure:: images/main_window.png
	:align: center

	Main window

Another window is opened for the calculation results. It has dual function
besides the results it has some logging role.

.. figure:: images/results.png
	:align: center

	Calculation results window

Loading sample data set
-----------------------

In the main window select **File/Load...** from the menu. Navigate to the 
*demodata* folder and select *test1.geo*. A log message appears in the 
*Calculation results* window, that data have been loaded.

View and edit fieldbooks
------------------------

The loaded fieldbooks can be opened in a mask window. Select 
**Edit/Observation** from the menu of the main window. In a cascading menu
the name of the loaded datasets popup, in this case only *test1* is visible,
select it. Fieldbook data are displayed in the default mask type.

.. figure:: images/fieldbook.png
	:align: center

	Fieldbook data

Data are arranged in a table, a row contains station or observed point data.
Column header can contain more labels (e.g. Signal height and Instrument 
height). The color of the values in the column can be different, signal heights
are black, instrument heights are red. Colors can be customized in the 
**File/Colors...** menu from the main window.

You can move in the table using the right side scroll bar, up and down arrow
keys, mouse wheel (Windows only), TAB/PgUp/PgDn/Ctrl-PgUp/Ctrl-PgDn keys.
You can edit the content of the active field, inside the field 
Home/End/Backspace/Delete/Insert keys can be used. If the edited value is not
valid (e.g. non-numeric value in the distance field) an error message 
appear and you can not leave the field until the field value is invalid.

View and edit coordinate lists
------------------------------

The loaded coordinate lists can be opened in a mask window. Select 
**Edit/Coordinates** from the menu of the main window. In a cascading menu
the name of the loaded datasets popup, in this case only *test1* is visible,
select it. Coordinate data are displayed in the default mask type.
Points are ordered in the table by point IDs.

.. figure:: images/coordinate.png
	:align: center

	Coordinate data

Data are arranged in a table, a row contains coordinates of a point.
Column header can contain more labels (e.g. Easting and Easting prelim.) 
The color of the values in the column can be different, eastings
are black, prelimanary eastings are red. Colors can be customized in the 
**File/Colors...** menu from the main window.

Field values can be edited in the same way as fieldbooks. The default mask for fieldbooks 
and coordanate lists can be configured in the *geo_easy.msk* file (*geoMaskDefault*
and *cooMaskDefault* variables)

Graphic window
--------------

Points having horizontal coordinates from all loaded data sets are displayed in
graphic window. Select **Window/New graphic window** from the menu of the main 
window or press F11 key to open a new graphic window.

.. figure:: images/graphic.png
	:align: center

	Graphic window

Enlarge the size of the graphic window, drag the corner of the window by the
mouse and press F3 to zoom to extent. Point symbols, IDs and observations are
visible in the graphic window. Red filled circles are stations but not oriented yet.

Preliminary coordinates
-----------------------

Let's calculate preliminary coordinates for those points which have no
coordinates sofar. Select **Calculate/Preliminary coordinates** from the menu
of any window.  You'll get a message, that there are no elevations for
some points.
Several points will be added to the graphic window and the
coordinate list. They have red point IDs to mark  preliminary coordinates.
Preliminary orientations and elevations are also calculated.

Press F5 button to turn of detail points, having a less crouded view in the 
graphic window (or **Commands/Detail points** from the menu of the graphic 
window).

.. figure:: images/graphic1.png
	:align: center

	Graphic window detail points turned out

::
	Note: Detail points have a numeric ID and have only a polar observation
	and were not station.

Calculations
------------

The calculation results are listed in the *Calculation results* window, if
you closed it, open it **Window/Log window** from the menu of the main window.
Calculation results are stored in a log file (*geo_easy.log* in the installation 
directory), so you can review them later.
There are calculations for a single point and multiple points. Single point
calculations are available from the popup menu, right click on the point in
the graphic window or coordinate list window or fieldbook window.
Multi point calculations are available from the *Calculation** menu of any 
window.

Whole circle bearing and distance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's calculate the whole circle bearing and distance between points 231 and 13.
Click on the point *231* with the right mouse button in the graphic window and
select **Bearing/Distance** from the popup menu. A selection list is displayed
with the point IDs having coordinates. You can select one or more point to
calculate bearing and distance. Select *13* from the list. The calculation
result is visible in the *Calculation results* window and the status bar of
the graphic window.

.. figure:: images/sel_point.png
	:align: center

	Point selection box

::
	|2017.11.26 09:22 - Bearing/Distance
	|Point num  Point num  Bearing   Distance Slope dis Zenith angle
	|231        13         293-08-21 4029.889

The slope distance and the zenith angle are calculated if the elevations of
the points are known.

::
	Note: You can use the right mouse button in the fieldbook or
	coordinate list windows, too. Right click on the point 
	ID and select **Calculate**, a cascading menu appear with the
	possible calculations for the point. If you select the 
	menu item with the point number an info box will be displayed about the
	point.

Orientation on a station
~~~~~~~~~~~~~~~~~~~~~~~~

Let's calculate orientation for a station *12*. Click on the point *12* with
the right mouse button in the graphic window. Select **Orientation** from the
popup window. A list with the backsight directions are displayed, orientation
angle in the first column and point ID in the second.

.. figure:: images/ori_list.png
	:align: center

	Backsight selection

Select both points (231, 11), use Shift or/and Ctrl keys to select more lines.
If you would like to select all rows, click on the *All* button.

A weighted average will be calculated for the mean orientation angle, the weights
are the distances. The calculation results are shown in the *Calculation results*
window.

```
	2017.11.26 09:47 - Orientation - 12
	Point num  Code         Direction    Bearing   Orient ang   Distance   e" e"max   E(m)
	231                     232-53-54   291-04-11    58-10-17   2243.319    0   16    0.010
	11                      334-20-10    32-30-25    58-10-15   1588.873   -1   19   -0.010
	Average orientation angle                        58-10-16
```

The *e\"* column contains the difference from the mean, *e\"(max)* is the
allowable difference fromthe Hungarian standard, *E(m)* is the linear 
difference at the backsight point.

Note that the fill color of the point marker of point *12* became green,
oriented station. The orientation angles and the mean are stored in the 
fieldbook, too. Select the orientation mask from the **Commands/Mask...**
in the fieldbook window to see them.

Orientation for all points
~~~~~~~~~~~~~~~~~~~~~~~~~~

You can calculate orientations for all station in a single step, select 
**Calculat/Orientations** from the menu of any window. Results are written to 
the *Calculation results* window. If the difference from the mean is too large 
a warning is displayed. Three other stations are also oriented.

::
	|2017.11.26 10:05 - Orientation - 11
	|Point num  Code         Direction    Bearing   Orient ang   Distance   e" e"max   E(m)
	|12                      295-54-35   212-30-25   276-35-50   1588.873    1   19    0.010
	|14                       71-01-11   347-36-58   276-35-47   1637.971   -1   18   -0.010
	|Average orientation angle                       276-35-48
::
	|2017.11.26 10:05 - Orientation - 231
	|Point num  Code         Direction    Bearing   Orient ang   Distance   e" e"max   E(m)
	|15                      341-58-03   222-18-10   240-20-07   2615.063   -1   14   -0.023
	|13                       52-48-11   293-08-21   240-20-10   4029.889    1   11    0.023
	|Average orientation angle                       240-20-08
::
	|2017.11.26 10:05 - Orientation - 16
	|Point num  Code         Direction    Bearing   Orient ang   Distance   e" e"max   E(m)
	|14                      290-57-39    51-22-38   120-24-59   1425.779   -2   20   -0.016
	|11                      355-25-59   115-51-02   120-25-03   1628.118    2   18    0.016
	|Average orientation angle                       120-25-01


Intersection
~~~~~~~~~~~~

Let's calculate the coordinates of point *5004* using intersection. Four 
directions were measured from point *11, 12, 231* and *16* to *5004*.
Station have to be oriented to be used in intersection. 
Right mouse button click on point *5004* in the graphic window and select
**Intersection** from the popup menu. A list of possible intersection 
directions are displayed in the selection window. The fieldbook name and the
point numbers are shown in the list (if more fieldbooks are loaded, stations
from any fieldbook can be used).
Select two directions *11* and *12* (best intersection angle).

.. figure:: images/intersection.png
	:align: center

	Intersection selection

::
	|2017.11.26 10:23 - Intersection
	|Point num  Code                E            N     Bearing
	|11                       91515.440     2815.220   243-57-51
	|12                       90661.580     1475.280   330-00-58
	|5004                     90246.207     2195.193



Resection
~~~~~~~~~

Arcsection
~~~~~~~~~~

Elevation calculation
~~~~~~~~~~~~~~~~~~~~~

Travese and trigonometric line
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Detail points
~~~~~~~~~~~~~

Regression calculation
----------------------

Regression line
~~~~~~~~~~~~~~~

Regression plane
~~~~~~~~~~~~~~~~

Coordinate transformation
-------------------------

Save to DXF file
----------------

