import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zipli/atoms/filled_button.dart';
import 'package:zipli/atoms/filled_tonal_button.dart';
import 'package:zipli/atoms/no_locations.dart';
import 'package:zipli/others/place_api.dart';
import 'package:zipli/others/trip_details.dart';
import 'package:uuid/uuid.dart';

import '../atoms/deletable_background.dart';
import '../atoms/place_list_tile.dart';
import '../molecules/trip_overview.dart';
import '../others/place_details.dart';
import '../others/place_search_delegate.dart';

enum StartOrEnd { start, end }

class NewTripPage extends StatefulWidget {
  static const id = '/new-trip';

  const NewTripPage({Key? key}) : super(key: key);

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final TripDetails _tripDetails = TripDetails(
    id: const Uuid().v4(),
    title: null,
    description: null,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 3)),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    places: <PlaceDetails>[],
  );
  final int _stepsCount = 4;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: const Text('Changes you made will not be saved.'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FilledButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.close),
          ),
          title: const Text('New Trip'),
        ),
        body: Stepper(
          currentStep: _currentIndex,
          onStepContinue: _onStepContinue,
          onStepTapped: _onStepTapped,
          controlsBuilder: _controlsBuilder,
          steps: [
            _buildDurationStep(),
            _buildPlacesStep(context),
            _buildTitleStep(),
            _buildOverviewStep(context),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _currentIndex == _stepsCount - 1
            ? FloatingActionButton.extended(
                onPressed: () {
                  _saveTripDetails(_tripDetails);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.done),
                label: const Text('Done'),
              )
            : null,
      ),
    );
  }

  void _onStepTapped(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _onStepContinue() {
    if (_currentIndex < 3) {
      setState(() {
        _currentIndex += 1;
      });
    }
  }

  Widget _controlsBuilder(BuildContext context, ControlsDetails details) {
    return details.currentStep == _stepsCount - 1
        ? Container()
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: details.onStepContinue!,
                child: const Text('NEXT'),
              ),
            ],
          );
  }

  Step _buildDurationStep() {
    return Step(
      title: const Text('Duration'),
      isActive: _currentIndex == 0,
      content: Column(
        children: [
          ListTile(
            title: Center(
              child: Text(DateFormat.yMMMMd().format(_tripDetails.startDate)),
            ),
            leading: const Text('From'),
            trailing: IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () => _pickDate(
                startOrEnd: StartOrEnd.start,
                initialDate: _tripDetails.startDate,
                firstDate: _tripDetails.startDate,
              ),
            ),
          ),
          ListTile(
            title: Center(
              child: Text(DateFormat.yMMMMd().format(_tripDetails.endDate)),
            ),
            leading: const Text('To'),
            trailing: IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () => _pickDate(
                startOrEnd: StartOrEnd.end,
                initialDate: _tripDetails.endDate,
                firstDate: _tripDetails.startDate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Step _buildPlacesStep(BuildContext context) {
    return Step(
      title: const Text('Places'),
      isActive: _currentIndex == 1,
      content: Column(
        children: [
          if (_tripDetails.places.isEmpty)
            const NoLocations()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tripDetails.places.length,
              itemBuilder: (context, index) => Dismissible(
                key: ValueKey(_tripDetails.places[index]),
                background: const DeletableBackground(),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    setState(() {
                      _tripDetails.places.removeAt(index);
                    });
                  }
                },
                child: PlaceListTile(
                  place: _tripDetails.places[index],
                  reorderable: false,
                ),
              ),
            ),
          FilledTonalButton(
            onPressed: _showPlaceSearch,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Step _buildTitleStep() {
    return Step(
      title: const Text('Title'),
      isActive: _currentIndex == 2,
      content: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: TextField(
          maxLength: 16,
          onChanged: ((newTitle) {
            setState(() {
              _tripDetails.title = newTitle;
            });
          }),
        ),
      ),
    );
  }

  Step _buildOverviewStep(BuildContext context) {
    return Step(
      title: const Text('Overview'),
      isActive: _currentIndex == 2,
      state: StepState.complete,
      content: TripOverview(_tripDetails),
    );
  }

  Future<void> _showPlaceSearch() async {
    final sessionToken = const Uuid().v4();
    final result = await showSearch(
      context: context,
      delegate: PlaceSearchDelegate(sessionToken),
    );

    final placeDetails = await _getPlaceDetails(result!.placeId);

    setState(() {
      _tripDetails.places.add(placeDetails);
    });
  }

  Future<PlaceDetails> _getPlaceDetails(String placeId) {
    final sessionToken = const Uuid().v4();
    final placeApiProvider = PlaceAPI(sessionToken: sessionToken);

    return placeApiProvider.getPlaceDetails(placeId);
  }

  Future<void> _pickDate({
    required StartOrEnd startOrEnd,
    required DateTime initialDate,
    required DateTime firstDate,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        startOrEnd == StartOrEnd.start
            ? _tripDetails.startDate = pickedDate
            : _tripDetails.endDate = pickedDate;
      });
    }

    if (_tripDetails.startDate.isAfter(_tripDetails.endDate)) {
      setState(() {
        _tripDetails.endDate =
            _tripDetails.startDate.add(const Duration(days: 1));
      });
    }
  }

  Future<void> _saveTripDetails(TripDetails tripDetails) async {
    final users = FirebaseFirestore.instance.collection('users');
    final me = users.doc(FirebaseAuth.instance.currentUser!.uid);
    final myTrips = me.collection('trips');

    myTrips
        .doc(tripDetails.id)
        .set(tripDetails.toFirestore())
        .then((value) => print('Trip saved!'))
        .catchError((error) => print(error));
  }
}
