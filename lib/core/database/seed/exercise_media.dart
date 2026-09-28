// Illustrations : jeu de donnees ouvert RepDB (repdb.co), licence gratuite
// pour usage commercial en app avec attribution (voir Reglages > A propos).
// Genere par script ponctuel non versionne : voir docs/ARCHITECTURE.md paragraphe 4.

/// Illustration d'un exercice integre, si RepDB en fournit une.
class ExerciseMedia {
  const ExerciseMedia({this.imageAsset});

  final String? imageAsset;
}

/// Illustrations des exercices integres (docs/SPEC.md paragraphe 5.1), par identifiant.
/// Les exercices perso n'y figurent pas : pas d'image de substitution pour eux.
final Map<String, ExerciseMedia> builtInExerciseMedia = {
  // Cable Woodchop et Oblique Crunch : pas d'exercice RepDB équivalent, et
  // l'image de secours (Russian Twist) ne correspondait pas assez au geste ;
  // icône générique plutôt qu'une image trompeuse.
  '509d3ccf-bf4e-411b-a5db-2d2e491f586c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/509d3ccf-bf4e-411b-a5db-2d2e491f586c.webp',
  ),
  'c152f391-b038-44f6-b8df-cfef1d1a789d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c152f391-b038-44f6-b8df-cfef1d1a789d.webp',
  ),
  '7c098dc4-7640-4b19-9dda-14dd6f4cb30a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7c098dc4-7640-4b19-9dda-14dd6f4cb30a.webp',
  ),
  '3b49eab5-f756-427e-8ee6-62ab6d6114bb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3b49eab5-f756-427e-8ee6-62ab6d6114bb.webp',
  ),
  '8087a454-a438-4c79-be98-f6670785da3e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8087a454-a438-4c79-be98-f6670785da3e.webp',
  ),
  '5bc61b55-5623-4618-a35e-f8dc3469c2ab': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5bc61b55-5623-4618-a35e-f8dc3469c2ab.webp',
  ),
  'eba26f67-c29f-44b6-99c6-0de4a0f8538c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/eba26f67-c29f-44b6-99c6-0de4a0f8538c.webp',
  ),
  'd5702b62-5375-434d-a0bb-f2c807c0b16a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d5702b62-5375-434d-a0bb-f2c807c0b16a.webp',
  ),
  'd160b037-2046-44ac-ba37-97784a8cade2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d160b037-2046-44ac-ba37-97784a8cade2.webp',
  ),
  'a6a15280-2533-4e58-9161-ba084762cae2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a6a15280-2533-4e58-9161-ba084762cae2.webp',
  ),
  '38ddc93c-6f92-455b-b95e-5691c1795135': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/38ddc93c-6f92-455b-b95e-5691c1795135.webp',
  ),
  '73749ee2-e236-4518-9b61-cb40ec2a43de': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/73749ee2-e236-4518-9b61-cb40ec2a43de.webp',
  ),
  '098dda1c-fc74-4fdb-a642-ba7ea248ec5f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/098dda1c-fc74-4fdb-a642-ba7ea248ec5f.webp',
  ),
  '47583cc9-fca6-419e-b35e-fff36173a232': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/47583cc9-fca6-419e-b35e-fff36173a232.webp',
  ),
  '245bdee8-147f-4d37-94cc-e181332b7ad1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/245bdee8-147f-4d37-94cc-e181332b7ad1.webp',
  ),
  '8c41cbe2-1578-43dd-86df-6564ca27b38a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8c41cbe2-1578-43dd-86df-6564ca27b38a.webp',
  ),
  '6fe95f09-8d9c-4d5d-947b-45c764b20235': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6fe95f09-8d9c-4d5d-947b-45c764b20235.webp',
  ),
  '5190e591-346d-4944-85aa-1204579521d0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5190e591-346d-4944-85aa-1204579521d0.webp',
  ),
  'f60801a4-8ec9-47bb-83ff-bbf9666388b7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f60801a4-8ec9-47bb-83ff-bbf9666388b7.webp',
  ),
  '7ab07103-9606-4546-a5bb-64f177a69d9d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7ab07103-9606-4546-a5bb-64f177a69d9d.webp',
  ),
  '03d4a6fc-2db5-4dc5-8d44-a2a259a69adb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/03d4a6fc-2db5-4dc5-8d44-a2a259a69adb.webp',
  ),
  '75458925-1deb-4d8f-9e4d-acc867a239c3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/75458925-1deb-4d8f-9e4d-acc867a239c3.webp',
  ),
  '34f65d65-43f7-4514-bbca-53564d21598c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/34f65d65-43f7-4514-bbca-53564d21598c.webp',
  ),
  '5179741d-05aa-4990-ad16-9665a20dbd92': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5179741d-05aa-4990-ad16-9665a20dbd92.webp',
  ),
  '79eccf4c-fc23-49ab-b784-89751a22fd73': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/79eccf4c-fc23-49ab-b784-89751a22fd73.webp',
  ),
  '301363f4-72bb-444e-8d4f-d8b88d6335b5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/301363f4-72bb-444e-8d4f-d8b88d6335b5.webp',
  ),
  'a24f7342-c801-4117-b4b3-6ade8e74c56f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a24f7342-c801-4117-b4b3-6ade8e74c56f.webp',
  ),
  '13f28c0f-077c-4fa9-84d8-30d648df14d3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/13f28c0f-077c-4fa9-84d8-30d648df14d3.webp',
  ),
  '9a30a91e-15af-47f4-ad8f-85e319946015': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9a30a91e-15af-47f4-ad8f-85e319946015.webp',
  ),
  '6740a133-6c05-41ed-8127-8f1f6164c9e5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6740a133-6c05-41ed-8127-8f1f6164c9e5.webp',
  ),
  '7bb3b65e-5521-4984-9c86-2febbf926946': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7bb3b65e-5521-4984-9c86-2febbf926946.webp',
  ),
  'f2a5e95c-2e81-412e-a09b-195be6a0187e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f2a5e95c-2e81-412e-a09b-195be6a0187e.webp',
  ),
  '89338203-11f8-4b91-9679-ceb8b8007859': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/89338203-11f8-4b91-9679-ceb8b8007859.webp',
  ),
  '9a930805-d3a8-4ec7-8bd7-e56d102526f6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9a930805-d3a8-4ec7-8bd7-e56d102526f6.webp',
  ),
  'a4557387-0d8b-4bcf-a076-073f5bd0fa42': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a4557387-0d8b-4bcf-a076-073f5bd0fa42.webp',
  ),
  'b9a7bb05-91e6-4d93-a091-8ed7f960ef2b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b9a7bb05-91e6-4d93-a091-8ed7f960ef2b.webp',
  ),
  '180bde98-3580-4f1b-9590-6d3da06a3545': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/180bde98-3580-4f1b-9590-6d3da06a3545.webp',
  ),
  'edb104a5-69ae-4d91-b9a6-e75301c69d9e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/edb104a5-69ae-4d91-b9a6-e75301c69d9e.webp',
  ),
  '958cebc1-cc66-46a3-8953-e5165f3aab3b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/958cebc1-cc66-46a3-8953-e5165f3aab3b.webp',
  ),
  '43fda7d6-f669-4451-b8b8-c35ad7f78de2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/43fda7d6-f669-4451-b8b8-c35ad7f78de2.webp',
  ),
  '623e03b7-0c53-4fc0-8a24-ca8f540d2024': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/623e03b7-0c53-4fc0-8a24-ca8f540d2024.webp',
  ),
  '5c1a1069-dcce-4766-bf32-9ea9b41364ad': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5c1a1069-dcce-4766-bf32-9ea9b41364ad.webp',
  ),
  '92727fe7-e5ff-45c1-b78b-49167e10f597': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/92727fe7-e5ff-45c1-b78b-49167e10f597.webp',
  ),
  'f198852a-9922-4172-b96d-5788dbce93b0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f198852a-9922-4172-b96d-5788dbce93b0.webp',
  ),
  '5871b2cb-cb62-4433-af1d-69da2e1d3c4d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5871b2cb-cb62-4433-af1d-69da2e1d3c4d.webp',
  ),
  '0eb0d8dd-a111-4723-829d-898eb7510e07': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0eb0d8dd-a111-4723-829d-898eb7510e07.webp',
  ),
  'dfe7d960-2a1d-46d4-b776-06753ca4742d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/dfe7d960-2a1d-46d4-b776-06753ca4742d.webp',
  ),
  'dfea8e4c-893a-4cb5-8169-b2c760909197': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/dfea8e4c-893a-4cb5-8169-b2c760909197.webp',
  ),
  '2a3695a8-e321-41e8-b813-8d670d4e6d9a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2a3695a8-e321-41e8-b813-8d670d4e6d9a.webp',
  ),
  '29340dd4-9001-41af-9487-497cc9d509ea': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/29340dd4-9001-41af-9487-497cc9d509ea.webp',
  ),
  '0799de68-e598-417c-94b5-6337886ff79e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0799de68-e598-417c-94b5-6337886ff79e.webp',
  ),
  'af9a04b8-51ea-4471-9ac6-b4dcace7374b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/af9a04b8-51ea-4471-9ac6-b4dcace7374b.webp',
  ),
  'dacaab3c-a348-42ac-a10d-3af05c04217e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/dacaab3c-a348-42ac-a10d-3af05c04217e.webp',
  ),
  '668d3ce5-cd09-489c-9d08-9a8c5a9b4624': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/668d3ce5-cd09-489c-9d08-9a8c5a9b4624.webp',
  ),
  '2ac9d721-8efa-49b3-9515-e801adeb2d32': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2ac9d721-8efa-49b3-9515-e801adeb2d32.webp',
  ),
  '00b3ba27-4c08-4434-9872-5c417020fc47': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/00b3ba27-4c08-4434-9872-5c417020fc47.webp',
  ),
  'd950f88f-43aa-42a5-bb72-5f1e0ae6818d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d950f88f-43aa-42a5-bb72-5f1e0ae6818d.webp',
  ),
  'e18ff616-b6a3-4144-ba8d-160abf2c9702': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e18ff616-b6a3-4144-ba8d-160abf2c9702.webp',
  ),
  'dd431227-4976-4d15-99bd-3b4761f72d42': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/dd431227-4976-4d15-99bd-3b4761f72d42.webp',
  ),
  '7ed2d047-670c-4504-bf79-2af4410294fe': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7ed2d047-670c-4504-bf79-2af4410294fe.webp',
  ),
  'faa9e60c-fb50-4a03-9f6c-2b23a39e4c93': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/faa9e60c-fb50-4a03-9f6c-2b23a39e4c93.webp',
  ),
  '161c2e50-cdca-40db-93fc-46d382ad07d5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/161c2e50-cdca-40db-93fc-46d382ad07d5.webp',
  ),
  '1c1f27ab-1bc0-4cca-a2bb-efcbdb90210c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/1c1f27ab-1bc0-4cca-a2bb-efcbdb90210c.webp',
  ),
  'b2fc25d3-6822-440c-bb4a-27ee6451b09f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b2fc25d3-6822-440c-bb4a-27ee6451b09f.webp',
  ),
  'f0ad8526-d436-4e42-a091-2f83435d8298': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f0ad8526-d436-4e42-a091-2f83435d8298.webp',
  ),
  'aa2b9ace-e01b-4e50-b42f-9e1cf9c11ae8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/aa2b9ace-e01b-4e50-b42f-9e1cf9c11ae8.webp',
  ),
  '923831df-b011-48a2-bceb-76c43352ec6e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/923831df-b011-48a2-bceb-76c43352ec6e.webp',
  ),
  '65579ec3-9c6b-4ea6-9095-6f6f046b6991': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/65579ec3-9c6b-4ea6-9095-6f6f046b6991.webp',
  ),
  '15e96124-a809-4909-b4e3-fb2c35d95ee7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/15e96124-a809-4909-b4e3-fb2c35d95ee7.webp',
  ),
  'c5a032a7-1202-4a42-b798-59cd894e4f4d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c5a032a7-1202-4a42-b798-59cd894e4f4d.webp',
  ),
  'c9488234-a6f9-4608-b44d-efba7e0fa00f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c9488234-a6f9-4608-b44d-efba7e0fa00f.webp',
  ),
  'e4d19cd8-90dc-4f55-a2e8-f28fb0aad261': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e4d19cd8-90dc-4f55-a2e8-f28fb0aad261.webp',
  ),
  '403f7bb2-9e0c-473c-aa45-520def47f63f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/403f7bb2-9e0c-473c-aa45-520def47f63f.webp',
  ),
  '2b07a0d8-e3c3-4ca7-8dde-d1cacda2ec86': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2b07a0d8-e3c3-4ca7-8dde-d1cacda2ec86.webp',
  ),
  '2860931c-d217-417d-bf03-47a66b2fc4c2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2860931c-d217-417d-bf03-47a66b2fc4c2.webp',
  ),
  '4a7a6a75-bd4e-4634-bfb0-ce24c5d3076b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4a7a6a75-bd4e-4634-bfb0-ce24c5d3076b.webp',
  ),
  '6defcd07-d1d2-45ef-9aa6-5f3db12987ea': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6defcd07-d1d2-45ef-9aa6-5f3db12987ea.webp',
  ),
  '439a5a42-c4ed-4326-97ec-89ac5eade633': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/439a5a42-c4ed-4326-97ec-89ac5eade633.webp',
  ),
  '0b702e73-365c-4e1b-914d-d24efd8e37ea': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0b702e73-365c-4e1b-914d-d24efd8e37ea.webp',
  ),
  'a010d43c-a711-4554-8adc-3e1b35e10da2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a010d43c-a711-4554-8adc-3e1b35e10da2.webp',
  ),
  'a886b5f2-b265-4f4f-89fb-b24e63e6848d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a886b5f2-b265-4f4f-89fb-b24e63e6848d.webp',
  ),
  '2a79d1bd-c3b5-4628-8a5b-ddeace90fc13': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2a79d1bd-c3b5-4628-8a5b-ddeace90fc13.webp',
  ),
  '55bcf59a-8db9-458d-82de-c5311ab9e540': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/55bcf59a-8db9-458d-82de-c5311ab9e540.webp',
  ),
  '105db7bb-9081-41c7-b1fa-dbeb4a8f6d8e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/105db7bb-9081-41c7-b1fa-dbeb4a8f6d8e.webp',
  ),
  '794b5675-7a1b-493b-b887-00e1a6314e28': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/794b5675-7a1b-493b-b887-00e1a6314e28.webp',
  ),
  '703db9b6-438a-49a5-959e-4c601ca562af': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/703db9b6-438a-49a5-959e-4c601ca562af.webp',
  ),
  'c933a066-df8f-4161-89be-acaaed331864': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c933a066-df8f-4161-89be-acaaed331864.webp',
  ),
  '611359a0-989a-4441-8002-8afe7dfcb074': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/611359a0-989a-4441-8002-8afe7dfcb074.webp',
  ),
  '77ada746-1af8-444d-9cf6-4a7d566740ff': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/77ada746-1af8-444d-9cf6-4a7d566740ff.webp',
  ),
  'd0ca37e6-d409-475a-943a-2def9a83033b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d0ca37e6-d409-475a-943a-2def9a83033b.webp',
  ),
  '23b06c18-563a-4524-a856-951442e370d4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/23b06c18-563a-4524-a856-951442e370d4.webp',
  ),
  '423707f1-ed08-41c2-b869-6a652ae570f7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/423707f1-ed08-41c2-b869-6a652ae570f7.webp',
  ),
  'f2d7addf-7592-4b86-994a-877a31d8aded': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f2d7addf-7592-4b86-994a-877a31d8aded.webp',
  ),
  '0535ecbb-802e-4116-b633-5d8e6f63b8f0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0535ecbb-802e-4116-b633-5d8e6f63b8f0.webp',
  ),
  'e59833c9-bf4c-4f7c-881d-05af04efe489': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e59833c9-bf4c-4f7c-881d-05af04efe489.webp',
  ),
  '97809c17-a63c-4cbb-a30f-c73eff146608': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/97809c17-a63c-4cbb-a30f-c73eff146608.webp',
  ),
  'aa650871-168f-4366-bc00-ccb97fd62160': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/aa650871-168f-4366-bc00-ccb97fd62160.webp',
  ),
  '185cc545-f9ac-4843-9634-009567667baa': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/185cc545-f9ac-4843-9634-009567667baa.webp',
  ),
  'ee0c19bf-ebdc-410b-85fc-2f113fe4fa43': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ee0c19bf-ebdc-410b-85fc-2f113fe4fa43.webp',
  ),
  'd867f7be-4255-4515-8681-45da58b60544': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d867f7be-4255-4515-8681-45da58b60544.webp',
  ),
  '3e977114-10bc-449e-bbf1-57eaa4d80d38': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3e977114-10bc-449e-bbf1-57eaa4d80d38.webp',
  ),
  'ebd16805-ac3c-48f9-9e89-e6d610e31e60': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ebd16805-ac3c-48f9-9e89-e6d610e31e60.webp',
  ),
  '46385882-42da-4dc1-9d18-bc261a9a5b7d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/46385882-42da-4dc1-9d18-bc261a9a5b7d.webp',
  ),
  'e238e8c5-5ae7-410c-abb3-c5f828c0084f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e238e8c5-5ae7-410c-abb3-c5f828c0084f.webp',
  ),
  '235c8187-5aa5-4d6d-a7dd-7efb9bbb3c32': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/235c8187-5aa5-4d6d-a7dd-7efb9bbb3c32.webp',
  ),
  '5e084351-37a2-46df-b976-5a6bfb2cb90b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5e084351-37a2-46df-b976-5a6bfb2cb90b.webp',
  ),
  'ddd71953-ed83-4765-8e6f-e9990aa95ec9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ddd71953-ed83-4765-8e6f-e9990aa95ec9.webp',
  ),
  '8cd2cf23-fa67-4d32-bbf6-82535e547690': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8cd2cf23-fa67-4d32-bbf6-82535e547690.webp',
  ),
  '9290f2aa-6d82-4832-a63f-8b3fcb8001bd': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9290f2aa-6d82-4832-a63f-8b3fcb8001bd.webp',
  ),
  'e94ef660-0038-44ac-8159-51def07a06e8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e94ef660-0038-44ac-8159-51def07a06e8.webp',
  ),
  'b7e2465e-6436-486f-81fa-6196d69886ba': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b7e2465e-6436-486f-81fa-6196d69886ba.webp',
  ),
  'bfd8ef44-9b4a-43ac-ab0a-61de2eec9e72': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/bfd8ef44-9b4a-43ac-ab0a-61de2eec9e72.webp',
  ),
  '57c58244-2315-4603-a408-3fc979636b86': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/57c58244-2315-4603-a408-3fc979636b86.webp',
  ),
  'f578ac63-1318-4cc9-9b1f-6af6e3ae1996': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f578ac63-1318-4cc9-9b1f-6af6e3ae1996.webp',
  ),
  '56674d24-6938-4ce7-bea4-8cb14559a1b5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/56674d24-6938-4ce7-bea4-8cb14559a1b5.webp',
  ),
  'a2afbca0-2286-4a35-8cd6-d971becf00a3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a2afbca0-2286-4a35-8cd6-d971becf00a3.webp',
  ),
  '1b888480-4273-4af3-a2dd-76b9ea21c103': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/1b888480-4273-4af3-a2dd-76b9ea21c103.webp',
  ),
  '56f6bcf0-3dcc-427a-b73a-c6cc3b0cc2b7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/56f6bcf0-3dcc-427a-b73a-c6cc3b0cc2b7.webp',
  ),
  'b5c5a175-587f-4b03-b6f0-8ebfa14e1b12': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b5c5a175-587f-4b03-b6f0-8ebfa14e1b12.webp',
  ),
  '392e2093-992c-4754-aa83-6b76eca95c53': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/392e2093-992c-4754-aa83-6b76eca95c53.webp',
  ),
  '7039d147-4a23-4633-80ab-e14fc5dbdf8c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7039d147-4a23-4633-80ab-e14fc5dbdf8c.webp',
  ),
  '657ea91a-2513-4035-90bb-07cfcd06c645': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/657ea91a-2513-4035-90bb-07cfcd06c645.webp',
  ),
  '5f38dd0e-4cbe-4466-8be5-a14924394728': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5f38dd0e-4cbe-4466-8be5-a14924394728.webp',
  ),
  'a0a5538b-b6cc-49b7-bff2-d9cd06b4d86f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a0a5538b-b6cc-49b7-bff2-d9cd06b4d86f.webp',
  ),
  '7642406e-6d19-4453-b963-173382b61849': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7642406e-6d19-4453-b963-173382b61849.webp',
  ),
  '9669c58a-0436-4884-9d88-7d7c3931fad3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9669c58a-0436-4884-9d88-7d7c3931fad3.webp',
  ),
  'f8b37a64-0e9e-4cf3-a6f3-b723945a8374': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f8b37a64-0e9e-4cf3-a6f3-b723945a8374.webp',
  ),
  '68f9d01d-7732-404a-a9a5-471f7114a513': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/68f9d01d-7732-404a-a9a5-471f7114a513.webp',
  ),
  'fd86a1d2-cd39-4466-9614-86647b56114b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/fd86a1d2-cd39-4466-9614-86647b56114b.webp',
  ),
  '798791fe-ec47-43d3-a641-491989a676be': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/798791fe-ec47-43d3-a641-491989a676be.webp',
  ),
  '9b6e5003-2c9d-438b-ad02-8b297306002c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9b6e5003-2c9d-438b-ad02-8b297306002c.webp',
  ),
  '7d34003d-c6cf-430b-8d6b-4039f58d8387': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7d34003d-c6cf-430b-8d6b-4039f58d8387.webp',
  ),
  'a69d8acb-812f-4cf0-8955-a245b9370b7e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a69d8acb-812f-4cf0-8955-a245b9370b7e.webp',
  ),
  '4f3c6b9a-199a-4d70-b1b9-f1a04b553b21': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4f3c6b9a-199a-4d70-b1b9-f1a04b553b21.webp',
  ),
  '91a65243-57b4-4c4b-8f1f-3f17fb07c41b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/91a65243-57b4-4c4b-8f1f-3f17fb07c41b.webp',
  ),
  '70d34e87-e00d-44c4-a3f4-092fba548046': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/70d34e87-e00d-44c4-a3f4-092fba548046.webp',
  ),
  'de24ff72-66d2-448f-8397-12cf12500349': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/de24ff72-66d2-448f-8397-12cf12500349.webp',
  ),
  'ac8077a6-a36d-4e1e-914c-42b2fa8c7bde': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ac8077a6-a36d-4e1e-914c-42b2fa8c7bde.webp',
  ),
  '3bd501b2-e32f-4d78-93a5-b6db62e066c0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3bd501b2-e32f-4d78-93a5-b6db62e066c0.webp',
  ),
  '0d1c4df9-635e-49ee-a056-596a73256840': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0d1c4df9-635e-49ee-a056-596a73256840.webp',
  ),
  '8929f745-d8ab-473a-80a4-67e94d13217f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8929f745-d8ab-473a-80a4-67e94d13217f.webp',
  ),
  '87412fd9-6835-48b4-ae5a-3b4f8df3b3e4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/87412fd9-6835-48b4-ae5a-3b4f8df3b3e4.webp',
  ),
  '87993ccb-1a17-4fa6-b5b8-80ed83656cfd': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/87993ccb-1a17-4fa6-b5b8-80ed83656cfd.webp',
  ),
  'c3409eab-add7-475b-9b6f-a8d1dbc170bc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c3409eab-add7-475b-9b6f-a8d1dbc170bc.webp',
  ),
  '4399c09c-6b24-4c96-8e58-f5668e127aeb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4399c09c-6b24-4c96-8e58-f5668e127aeb.webp',
  ),
  '07132602-7bf7-4e64-b694-797a40f78e63': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/07132602-7bf7-4e64-b694-797a40f78e63.webp',
  ),
  'c3b01bdc-ccac-4048-bfa1-111496207740': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c3b01bdc-ccac-4048-bfa1-111496207740.webp',
  ),
  'fb0dd56c-7ed0-4379-836f-55aa717289a1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/fb0dd56c-7ed0-4379-836f-55aa717289a1.webp',
  ),
  '4d14ee2e-c88f-44d0-82b8-350a48130ebc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4d14ee2e-c88f-44d0-82b8-350a48130ebc.webp',
  ),
  '4b34345c-89d3-47fd-b797-81e69ed6b7ed': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4b34345c-89d3-47fd-b797-81e69ed6b7ed.webp',
  ),
  'f838b38a-98e5-475b-a87a-dea7e2ad6331': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f838b38a-98e5-475b-a87a-dea7e2ad6331.webp',
  ),
  '5749cc60-3d4d-439f-8456-17a726c14482': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5749cc60-3d4d-439f-8456-17a726c14482.webp',
  ),
  '0217590a-9ca5-4fd5-abc9-45313c390f8a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0217590a-9ca5-4fd5-abc9-45313c390f8a.webp',
  ),
  'a595a6b1-c4f3-4dea-9cc0-0a9431f531a9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a595a6b1-c4f3-4dea-9cc0-0a9431f531a9.webp',
  ),
  '18092716-c8a7-4492-ad2f-78050a0b6d65': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/18092716-c8a7-4492-ad2f-78050a0b6d65.webp',
  ),
  '6fc97062-4655-40a1-a9d5-10d36a1567d4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6fc97062-4655-40a1-a9d5-10d36a1567d4.webp',
  ),
  'ea18253d-b686-4136-8c0d-c6b749d47ddb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ea18253d-b686-4136-8c0d-c6b749d47ddb.webp',
  ),
  'ec6b3059-3127-412a-925e-36264358fb37': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ec6b3059-3127-412a-925e-36264358fb37.webp',
  ),
  'c4ce8001-8719-4691-91b0-cc647a5354c2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c4ce8001-8719-4691-91b0-cc647a5354c2.webp',
  ),
  '7f377fc6-9445-4afe-b114-705c6e6656cf': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7f377fc6-9445-4afe-b114-705c6e6656cf.webp',
  ),
  '8b10c013-b224-4126-8edc-399ca9927ca5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8b10c013-b224-4126-8edc-399ca9927ca5.webp',
  ),
  'e355ffe8-7720-42a7-967f-9224a03da6f9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e355ffe8-7720-42a7-967f-9224a03da6f9.webp',
  ),
  '97ef1d5a-f5ac-4602-96d3-5ae619cb4551': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/97ef1d5a-f5ac-4602-96d3-5ae619cb4551.webp',
  ),
  'f6f7361d-b11d-4663-8027-a274ae6220e4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f6f7361d-b11d-4663-8027-a274ae6220e4.webp',
  ),
  '3cdd0e4b-1cbc-42de-a1d1-958e4fc6fa54': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3cdd0e4b-1cbc-42de-a1d1-958e4fc6fa54.webp',
  ),
  'a29d240f-2485-494e-80d0-6f5bff2616de': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a29d240f-2485-494e-80d0-6f5bff2616de.webp',
  ),
  '04d803ef-e339-459a-b4e8-c4e3ae1ebe10': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/04d803ef-e339-459a-b4e8-c4e3ae1ebe10.webp',
  ),
  '83d912ef-2dee-4256-9a56-627b918885b2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/83d912ef-2dee-4256-9a56-627b918885b2.webp',
  ),
  'bb138595-60e6-4eb9-b783-5105ab76e6fc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/bb138595-60e6-4eb9-b783-5105ab76e6fc.webp',
  ),
  'a2952370-fab1-40ee-b01d-9e9ccbfdef91': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a2952370-fab1-40ee-b01d-9e9ccbfdef91.webp',
  ),
  '3847a1d6-5818-428f-a31e-ddc764ea805c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3847a1d6-5818-428f-a31e-ddc764ea805c.webp',
  ),
  '348d0ef8-d9c0-40c5-b2bd-a6e3bd70347d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/348d0ef8-d9c0-40c5-b2bd-a6e3bd70347d.webp',
  ),
  '7323de34-2cd7-4f0f-b736-b638276ae075': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7323de34-2cd7-4f0f-b736-b638276ae075.webp',
  ),
  '008a0633-394b-4ca6-9568-29232ab85ddc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/008a0633-394b-4ca6-9568-29232ab85ddc.webp',
  ),
  'dd121a38-44cc-40fe-8062-3cfeaa267728': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/dd121a38-44cc-40fe-8062-3cfeaa267728.webp',
  ),
  '42868baf-3ade-4aaf-b843-b5d194790900': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/42868baf-3ade-4aaf-b843-b5d194790900.webp',
  ),
  'a60b9cd0-f487-4402-bd9b-92660afaae78': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a60b9cd0-f487-4402-bd9b-92660afaae78.webp',
  ),
  '94d1f14c-a7ad-4207-8508-923d166be5a6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/94d1f14c-a7ad-4207-8508-923d166be5a6.webp',
  ),
  '8cd64d24-20a5-4c0a-923a-9b826da44783': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8cd64d24-20a5-4c0a-923a-9b826da44783.webp',
  ),
  '9663028d-f4df-42d2-990c-5b2956376ba1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9663028d-f4df-42d2-990c-5b2956376ba1.webp',
  ),
  'd3f4779f-cbc3-4f54-82df-6bcf083d116e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d3f4779f-cbc3-4f54-82df-6bcf083d116e.webp',
  ),
  '1ac06ed7-eb23-45cd-9c64-4163aa8fec90': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/1ac06ed7-eb23-45cd-9c64-4163aa8fec90.webp',
  ),
  '7e8d7ccd-a4d4-4b20-9c3a-3839cbf30bfd': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7e8d7ccd-a4d4-4b20-9c3a-3839cbf30bfd.webp',
  ),
  '727398fb-66d3-4ad3-897b-2078242eea2d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/727398fb-66d3-4ad3-897b-2078242eea2d.webp',
  ),
  '9e753f77-c697-46c6-8d6f-8d33d96c0a06': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9e753f77-c697-46c6-8d6f-8d33d96c0a06.webp',
  ),
  '1888d084-c635-4386-89e6-d9d448444e9e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/1888d084-c635-4386-89e6-d9d448444e9e.webp',
  ),
  'de9e221b-6909-4a26-9fa0-58e49190753d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/de9e221b-6909-4a26-9fa0-58e49190753d.webp',
  ),
  '95ece427-7c91-4b19-963c-20c92915e256': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/95ece427-7c91-4b19-963c-20c92915e256.webp',
  ),
  'af9b3bd9-6eb6-47fd-9740-9a9c178d4929': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/af9b3bd9-6eb6-47fd-9740-9a9c178d4929.webp',
  ),
  '6a9c2e12-eeb4-46ff-92b8-a275537e8f59': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6a9c2e12-eeb4-46ff-92b8-a275537e8f59.webp',
  ),
  'd35dc3a3-d550-4656-a588-67be5ea351c5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d35dc3a3-d550-4656-a588-67be5ea351c5.webp',
  ),
  'ddb41974-5323-4770-a51f-e9df8f9446c1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ddb41974-5323-4770-a51f-e9df8f9446c1.webp',
  ),
  '343707a9-e3e8-4299-b4ed-f6423e0c32f5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/343707a9-e3e8-4299-b4ed-f6423e0c32f5.webp',
  ),
  '0135d048-4704-4888-8848-843ab40a134d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0135d048-4704-4888-8848-843ab40a134d.webp',
  ),
  'ae893317-cf5b-4677-8439-bc126bcc1406': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ae893317-cf5b-4677-8439-bc126bcc1406.webp',
  ),
  'e1e5cb62-57eb-4f6e-9fb5-ef9ec78a47df': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e1e5cb62-57eb-4f6e-9fb5-ef9ec78a47df.webp',
  ),
  '5ccf52b7-558c-4876-993e-ff9c2dbffc04': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5ccf52b7-558c-4876-993e-ff9c2dbffc04.webp',
  ),
  '76482391-3586-42bc-b813-4c5964699930': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/76482391-3586-42bc-b813-4c5964699930.webp',
  ),
  '0b306edc-bba1-47d8-b2e9-389d935c85e3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0b306edc-bba1-47d8-b2e9-389d935c85e3.webp',
  ),
  '9a746e54-55c8-4e7b-95c7-2bf7c6a5f32b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9a746e54-55c8-4e7b-95c7-2bf7c6a5f32b.webp',
  ),
  '7adbce18-f343-4b87-8421-b231d38e7130': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7adbce18-f343-4b87-8421-b231d38e7130.webp',
  ),
  '203d8f1f-9580-491a-a0c7-7df37c71e23b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/203d8f1f-9580-491a-a0c7-7df37c71e23b.webp',
  ),
  'df02d4e9-5529-4228-9bc7-8328ac79fed3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/df02d4e9-5529-4228-9bc7-8328ac79fed3.webp',
  ),
  '46a7bdf6-e2a9-4674-ad18-3de4a8c9b305': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/46a7bdf6-e2a9-4674-ad18-3de4a8c9b305.webp',
  ),
  'd599c721-98e8-447e-80c5-bbb00b99bca0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d599c721-98e8-447e-80c5-bbb00b99bca0.webp',
  ),
  '4524d98c-e548-4741-bdc3-f38904e4595f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4524d98c-e548-4741-bdc3-f38904e4595f.webp',
  ),
  '0e1e9a69-1f0c-40f3-8e7e-f1a78c339074': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0e1e9a69-1f0c-40f3-8e7e-f1a78c339074.webp',
  ),
  '0bfa393d-dfcf-44c9-840a-242f9d26f750': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0bfa393d-dfcf-44c9-840a-242f9d26f750.webp',
  ),
  'b619dc24-e4b9-42a7-8864-4f92fbc5cbca': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b619dc24-e4b9-42a7-8864-4f92fbc5cbca.webp',
  ),
  'a4ed5818-bdb5-414c-98a6-e256bc52fa19': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a4ed5818-bdb5-414c-98a6-e256bc52fa19.webp',
  ),
  'cc55202e-9762-4725-92f2-5f66a3981c04': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/cc55202e-9762-4725-92f2-5f66a3981c04.webp',
  ),
  '3afa3729-d570-4eea-886d-1948e2ff5516': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3afa3729-d570-4eea-886d-1948e2ff5516.webp',
  ),
  'bacbde0b-5350-4b0d-8a5a-fffb59105861': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/bacbde0b-5350-4b0d-8a5a-fffb59105861.webp',
  ),
  '0e72424b-0122-4bf0-a729-eccf9fb085e1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0e72424b-0122-4bf0-a729-eccf9fb085e1.webp',
  ),
  '9c782953-a669-4817-97ec-7f2d3e237477': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9c782953-a669-4817-97ec-7f2d3e237477.webp',
  ),
  '076999df-dbdd-4cb3-adc2-3cc98e0704e4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/076999df-dbdd-4cb3-adc2-3cc98e0704e4.webp',
  ),
  'd08a5f9a-dc61-4c81-9bb5-855e2b04126b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d08a5f9a-dc61-4c81-9bb5-855e2b04126b.webp',
  ),
  '6e199077-7d2b-4b45-9870-dcfb52ba6efe': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6e199077-7d2b-4b45-9870-dcfb52ba6efe.webp',
  ),
  '40be005d-6099-4f59-b8d6-5f9ab9b2ff08': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/40be005d-6099-4f59-b8d6-5f9ab9b2ff08.webp',
  ),
  '70cd2005-fd18-4b1f-9bb5-e7000c212d81': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/70cd2005-fd18-4b1f-9bb5-e7000c212d81.webp',
  ),
  'fe657b03-8e3a-4de4-b9ea-93ca048c772c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/fe657b03-8e3a-4de4-b9ea-93ca048c772c.webp',
  ),
  '630c03e7-9a63-4fd0-a28f-d3a2c29577d4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/630c03e7-9a63-4fd0-a28f-d3a2c29577d4.webp',
  ),
  '2fe490b4-2089-44ed-8ed9-f1213efdd433': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2fe490b4-2089-44ed-8ed9-f1213efdd433.webp',
  ),
  'b1710958-f5df-41d0-9ffd-3b835025695e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b1710958-f5df-41d0-9ffd-3b835025695e.webp',
  ),
  '3ce4b10d-b366-424c-8d7c-9261c7d832ff': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3ce4b10d-b366-424c-8d7c-9261c7d832ff.webp',
  ),
  '7e039720-8fb9-43f0-87ca-3698a92ba9df': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7e039720-8fb9-43f0-87ca-3698a92ba9df.webp',
  ),
  '8435ba3b-9853-4608-85f7-90fc2d2d06a7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8435ba3b-9853-4608-85f7-90fc2d2d06a7.webp',
  ),
  '28c2d825-6da9-4f6b-9d86-f1d2431d7a5a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/28c2d825-6da9-4f6b-9d86-f1d2431d7a5a.webp',
  ),
  '2836bf5c-7006-4020-af7e-ad9598b388a9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2836bf5c-7006-4020-af7e-ad9598b388a9.webp',
  ),
  '0ddf510a-c964-47ec-acd9-fb1f9277fffa': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0ddf510a-c964-47ec-acd9-fb1f9277fffa.webp',
  ),
  'eb5b6233-f868-4b8d-9cf4-f0663a8d397f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/eb5b6233-f868-4b8d-9cf4-f0663a8d397f.webp',
  ),
  '3a57c13f-992a-4f5a-a04c-2af9b59b86e6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3a57c13f-992a-4f5a-a04c-2af9b59b86e6.webp',
  ),
  '3977af7b-b392-49e8-8542-a11e9477edd8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3977af7b-b392-49e8-8542-a11e9477edd8.webp',
  ),
  'e91c5fca-d17a-49d5-a141-f6f5629ba8e0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e91c5fca-d17a-49d5-a141-f6f5629ba8e0.webp',
  ),
  'a62ed0d6-7a74-4003-8e06-69e572b2ca07': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a62ed0d6-7a74-4003-8e06-69e572b2ca07.webp',
  ),
  '2ff90875-3d2a-4914-90e9-dd62e5978ab8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2ff90875-3d2a-4914-90e9-dd62e5978ab8.webp',
  ),
  '01a769ec-4b90-4dfe-86c9-ecb2a169e489': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/01a769ec-4b90-4dfe-86c9-ecb2a169e489.webp',
  ),
  '4334a753-6919-4a79-bbf7-2f478ecf734e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4334a753-6919-4a79-bbf7-2f478ecf734e.webp',
  ),
  'd829b73d-80c9-48e9-9cca-8e1a8cdc8020': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d829b73d-80c9-48e9-9cca-8e1a8cdc8020.webp',
  ),
  '7242b72f-4541-4d92-b394-e72c2155c770': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7242b72f-4541-4d92-b394-e72c2155c770.webp',
  ),
  '42ef9127-a691-4616-9636-25f15b4959c8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/42ef9127-a691-4616-9636-25f15b4959c8.webp',
  ),
  'cbf35bf3-3dbf-4a2c-abd5-d2a51241d1b3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/cbf35bf3-3dbf-4a2c-abd5-d2a51241d1b3.webp',
  ),
  '42326ed2-bc62-4a8e-84a9-a03997cffcc1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/42326ed2-bc62-4a8e-84a9-a03997cffcc1.webp',
  ),
  '4ac40ec7-1647-4a19-8383-05406bd7cc43': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4ac40ec7-1647-4a19-8383-05406bd7cc43.webp',
  ),
  '828a3dcf-aa93-4eb4-a539-31dff2fcae34': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/828a3dcf-aa93-4eb4-a539-31dff2fcae34.webp',
  ),
  'a35ddc4f-e66d-4c86-a0fd-a94f33c3b09b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a35ddc4f-e66d-4c86-a0fd-a94f33c3b09b.webp',
  ),
  '60c3e4aa-da42-4379-93ec-4b5b683ec331': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/60c3e4aa-da42-4379-93ec-4b5b683ec331.webp',
  ),
  '3cc261d6-4763-49f5-8cd1-36d299c8015e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3cc261d6-4763-49f5-8cd1-36d299c8015e.webp',
  ),
  '26151e87-7d3f-43fa-9ad5-820e0d435b2e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/26151e87-7d3f-43fa-9ad5-820e0d435b2e.webp',
  ),
  '3c3d950e-c322-4313-a3e5-22e49c9ff6da': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3c3d950e-c322-4313-a3e5-22e49c9ff6da.webp',
  ),
  '2c96ed80-431d-4a6f-a25d-8c2af10375f6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2c96ed80-431d-4a6f-a25d-8c2af10375f6.webp',
  ),
  'd213fcef-c1bf-4bc8-bca3-7d75b862ba9d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d213fcef-c1bf-4bc8-bca3-7d75b862ba9d.webp',
  ),
  '284cc910-fad0-4a3b-9df5-d9bc22f4eece': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/284cc910-fad0-4a3b-9df5-d9bc22f4eece.webp',
  ),
  'c8eb25e5-c252-4696-8ef9-cef2f065d86d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c8eb25e5-c252-4696-8ef9-cef2f065d86d.webp',
  ),
  '908ba582-47b6-4bc7-8371-b3d51c6134d1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/908ba582-47b6-4bc7-8371-b3d51c6134d1.webp',
  ),
  '8ecce382-b1de-4099-977c-93a09931dd93': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8ecce382-b1de-4099-977c-93a09931dd93.webp',
  ),
  'c1b193cd-bd5f-4d4d-b026-e34d115c8145': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c1b193cd-bd5f-4d4d-b026-e34d115c8145.webp',
  ),
  '082238ea-51de-407e-94dd-8b17fe1e2ac9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/082238ea-51de-407e-94dd-8b17fe1e2ac9.webp',
  ),
  '80e5b4f2-4609-41bb-9b00-f8483956feca': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/80e5b4f2-4609-41bb-9b00-f8483956feca.webp',
  ),
  'b82d18d2-155a-41b5-8cbd-dda43b326720': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b82d18d2-155a-41b5-8cbd-dda43b326720.webp',
  ),
  '2d4c510c-ccc7-47ae-bc92-35783694b47b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2d4c510c-ccc7-47ae-bc92-35783694b47b.webp',
  ),
  '4a16e8ba-bc47-4bc2-8706-ecaa54696170': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4a16e8ba-bc47-4bc2-8706-ecaa54696170.webp',
  ),
  'b3d38a02-ead7-4d48-ac4e-0301b9fc71d5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b3d38a02-ead7-4d48-ac4e-0301b9fc71d5.webp',
  ),
  '6af7e57a-e809-49a2-96f4-5a7d89993955': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6af7e57a-e809-49a2-96f4-5a7d89993955.webp',
  ),
  'b5a7fa85-a5f3-4cc7-909a-1fc474cf4bbc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b5a7fa85-a5f3-4cc7-909a-1fc474cf4bbc.webp',
  ),
  'b2de097b-a6b3-46af-89c9-7a04946348ff': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b2de097b-a6b3-46af-89c9-7a04946348ff.webp',
  ),
  '531035ef-4015-4b55-8202-6dedd4e229a7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/531035ef-4015-4b55-8202-6dedd4e229a7.webp',
  ),
  '0fc2902a-2633-46a1-91aa-a8e621ca5f92': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0fc2902a-2633-46a1-91aa-a8e621ca5f92.webp',
  ),
  '03242c97-8554-46c9-a4cc-06654b05da77': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/03242c97-8554-46c9-a4cc-06654b05da77.webp',
  ),
  'a8d586c2-111b-4669-8f48-843eaa6aabda': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a8d586c2-111b-4669-8f48-843eaa6aabda.webp',
  ),
  'afbe7f11-9741-40de-828d-7a772c0a3dc7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/afbe7f11-9741-40de-828d-7a772c0a3dc7.webp',
  ),
  '1a99414d-de74-449c-b451-18df65a578f9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/1a99414d-de74-449c-b451-18df65a578f9.webp',
  ),
  'b4344c5d-d5e6-4d6f-bf94-5c56ef099c27': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b4344c5d-d5e6-4d6f-bf94-5c56ef099c27.webp',
  ),
  '966b26d0-e790-45f0-ba56-ac43392a1ef6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/966b26d0-e790-45f0-ba56-ac43392a1ef6.webp',
  ),
  '5dd5d556-4c80-441d-bac7-9a5dff9e2829': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5dd5d556-4c80-441d-bac7-9a5dff9e2829.webp',
  ),
  'd499a026-bf98-4b63-8e13-987ea3b7cac6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d499a026-bf98-4b63-8e13-987ea3b7cac6.webp',
  ),
  'fb679dc3-1615-43f0-b2e0-b326cbbe8d54': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/fb679dc3-1615-43f0-b2e0-b326cbbe8d54.webp',
  ),
  '5d9f9e8b-2837-4096-9c1e-1a23db381e8f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5d9f9e8b-2837-4096-9c1e-1a23db381e8f.webp',
  ),
  '0920f160-678c-4a53-b7f3-b4fc13d9ef9e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0920f160-678c-4a53-b7f3-b4fc13d9ef9e.webp',
  ),
  'a1034b9a-87b2-4286-8814-0332f8285156': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a1034b9a-87b2-4286-8814-0332f8285156.webp',
  ),
  '4ccd8eec-3dbb-4fda-8158-24aaedacebf6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4ccd8eec-3dbb-4fda-8158-24aaedacebf6.webp',
  ),
  '82057819-31dc-468b-8dc4-3f5dc8372d9a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/82057819-31dc-468b-8dc4-3f5dc8372d9a.webp',
  ),
  'c01e16e0-e651-42ff-aef6-3a507a24fa15': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c01e16e0-e651-42ff-aef6-3a507a24fa15.webp',
  ),
  'cf82f953-384a-445e-9a8f-1f7817f299e2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/cf82f953-384a-445e-9a8f-1f7817f299e2.webp',
  ),
  'de83439a-c328-4970-bc6b-76cc22065a62': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/de83439a-c328-4970-bc6b-76cc22065a62.webp',
  ),
  'a8f4a8b3-ff9a-48ee-a89e-2d7aae3dcccc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a8f4a8b3-ff9a-48ee-a89e-2d7aae3dcccc.webp',
  ),
  '8dcc9c79-c124-4d77-8ebb-2701384ad75b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8dcc9c79-c124-4d77-8ebb-2701384ad75b.webp',
  ),
  '5150644b-c284-4203-b42f-63317bf52ee0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5150644b-c284-4203-b42f-63317bf52ee0.webp',
  ),
  'fda0ee88-4064-4292-a056-613d9e3ef3aa': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/fda0ee88-4064-4292-a056-613d9e3ef3aa.webp',
  ),
  '0e2f1cae-6ebc-49a6-9e44-28d46d103acb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0e2f1cae-6ebc-49a6-9e44-28d46d103acb.webp',
  ),
  'b17947a4-1fac-42ca-8b17-02b541b077ba': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b17947a4-1fac-42ca-8b17-02b541b077ba.webp',
  ),
  '725fd641-54f2-4107-8aa3-2491edb551ef': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/725fd641-54f2-4107-8aa3-2491edb551ef.webp',
  ),
  '1e1b3bc4-9fa0-42a0-97e8-0b8a04767886': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/1e1b3bc4-9fa0-42a0-97e8-0b8a04767886.webp',
  ),
  'c9dfb3b6-2093-47a1-b8a7-af405b93dde6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c9dfb3b6-2093-47a1-b8a7-af405b93dde6.webp',
  ),
  'e5ffe689-6c6b-409c-afb2-4eef0c887030': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e5ffe689-6c6b-409c-afb2-4eef0c887030.webp',
  ),
  'b24a1e27-79bc-48a7-ab0b-9db4279efd3d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b24a1e27-79bc-48a7-ab0b-9db4279efd3d.webp',
  ),
  'a677b733-3844-4bd5-9522-e75d1a3846bb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a677b733-3844-4bd5-9522-e75d1a3846bb.webp',
  ),
  '9cb7c8a6-4cce-4fe1-b775-137614d50d6d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9cb7c8a6-4cce-4fe1-b775-137614d50d6d.webp',
  ),
  'cd926638-36f1-4496-aebe-788409097716': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/cd926638-36f1-4496-aebe-788409097716.webp',
  ),
  '537f1255-61cf-4f9e-925a-dc2b8e32bd46': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/537f1255-61cf-4f9e-925a-dc2b8e32bd46.webp',
  ),
  'f8d46f77-04c4-4118-8408-f2d7c33eae66': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f8d46f77-04c4-4118-8408-f2d7c33eae66.webp',
  ),
  'c9427eb3-2af8-4be9-8f53-b63fedd2b016': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c9427eb3-2af8-4be9-8f53-b63fedd2b016.webp',
  ),
  '2f195e79-f330-4073-b1c8-8ec4582ccc40': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2f195e79-f330-4073-b1c8-8ec4582ccc40.webp',
  ),
  '54b192da-bfb8-4bc4-a6c8-f391baa59f6d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/54b192da-bfb8-4bc4-a6c8-f391baa59f6d.webp',
  ),
  'aa08d0f9-9995-4ac7-8fb5-002029ba20ec': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/aa08d0f9-9995-4ac7-8fb5-002029ba20ec.webp',
  ),
  '97f65eca-a86a-4501-9bd9-da77f19616cc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/97f65eca-a86a-4501-9bd9-da77f19616cc.webp',
  ),
  '56436b4f-0725-44ec-8e1d-8cd969b45c08': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/56436b4f-0725-44ec-8e1d-8cd969b45c08.webp',
  ),
  '31782d1b-4c18-4249-9379-aa8294184b28': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/31782d1b-4c18-4249-9379-aa8294184b28.webp',
  ),
  '2451cd64-d00f-4c1d-8bce-4310487f9ae2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2451cd64-d00f-4c1d-8bce-4310487f9ae2.webp',
  ),
  '0b2aec62-73ee-4b6c-8f0a-c43bd30ade1f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0b2aec62-73ee-4b6c-8f0a-c43bd30ade1f.webp',
  ),
  'fe6d974a-695e-4b53-a609-ebb80444a520': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/fe6d974a-695e-4b53-a609-ebb80444a520.webp',
  ),
  '6165d627-7009-4bc3-a1d7-5e0d85f483b6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6165d627-7009-4bc3-a1d7-5e0d85f483b6.webp',
  ),
  '8f649c56-5004-4604-8759-378ffab08177': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8f649c56-5004-4604-8759-378ffab08177.webp',
  ),
  '7c32ad0e-f0d9-4472-8ba6-a86bb20564b1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7c32ad0e-f0d9-4472-8ba6-a86bb20564b1.webp',
  ),
  '824e77e5-86f2-48de-8d97-040f36886035': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/824e77e5-86f2-48de-8d97-040f36886035.webp',
  ),
  'dae3e6b7-742a-4b24-83e7-69259f0e2d35': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/dae3e6b7-742a-4b24-83e7-69259f0e2d35.webp',
  ),
  '57822d48-941d-42d5-aa53-cae3e00dff9d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/57822d48-941d-42d5-aa53-cae3e00dff9d.webp',
  ),
  '16b9c59b-8d27-4e2a-9af2-605a28c591df': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/16b9c59b-8d27-4e2a-9af2-605a28c591df.webp',
  ),
  '9284fb9c-7bcc-4813-88d5-4f4e4a643bfc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9284fb9c-7bcc-4813-88d5-4f4e4a643bfc.webp',
  ),
  '913bf57e-5d1f-4983-a925-95fb4668ea1b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/913bf57e-5d1f-4983-a925-95fb4668ea1b.webp',
  ),
  'ecba1aba-c325-4ed3-abbc-481eb8e3968e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ecba1aba-c325-4ed3-abbc-481eb8e3968e.webp',
  ),
  '6c1821c9-b446-4f58-9660-3f7e2a0655fb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6c1821c9-b446-4f58-9660-3f7e2a0655fb.webp',
  ),
  'b6aacff4-02cc-49ac-8ae5-57d3661f27f7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b6aacff4-02cc-49ac-8ae5-57d3661f27f7.webp',
  ),
  'e13b172d-7725-4a43-9d0c-ade84c2fdd2c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e13b172d-7725-4a43-9d0c-ade84c2fdd2c.webp',
  ),
  '932dc483-6091-40fc-a1fd-7515024e8e91': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/932dc483-6091-40fc-a1fd-7515024e8e91.webp',
  ),
  'ad6083a8-4105-45c1-b1f5-6f35f6b4b439': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ad6083a8-4105-45c1-b1f5-6f35f6b4b439.webp',
  ),
  'a6b874aa-1f28-4c95-afa9-71d603d8481e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a6b874aa-1f28-4c95-afa9-71d603d8481e.webp',
  ),
  '5022cce8-272f-407c-af19-4609f428f7a3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5022cce8-272f-407c-af19-4609f428f7a3.webp',
  ),
  '4abe0564-16f2-4d5a-b451-5f5bf6d90769': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4abe0564-16f2-4d5a-b451-5f5bf6d90769.webp',
  ),
  '497be902-6e38-478f-b0e6-ca53994b0dab': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/497be902-6e38-478f-b0e6-ca53994b0dab.webp',
  ),
  '683988d5-be0f-4170-acce-d2b674a91e8c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/683988d5-be0f-4170-acce-d2b674a91e8c.webp',
  ),
  'acb53799-5aa9-46a3-9f2c-1888ddffaec6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/acb53799-5aa9-46a3-9f2c-1888ddffaec6.webp',
  ),
  'e6eb2226-92df-4a20-97ac-9f3c3a42cfb9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e6eb2226-92df-4a20-97ac-9f3c3a42cfb9.webp',
  ),
  '9c7343bb-83c6-4d17-9178-7b485fc23076': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9c7343bb-83c6-4d17-9178-7b485fc23076.webp',
  ),
  '093b8c50-6ee0-4f57-b455-e916bfdf8d32': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/093b8c50-6ee0-4f57-b455-e916bfdf8d32.webp',
  ),
  'c56d936d-481b-4456-a96d-605c7eed13d7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c56d936d-481b-4456-a96d-605c7eed13d7.webp',
  ),
  '88886693-9386-4322-af65-694e77784898': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/88886693-9386-4322-af65-694e77784898.webp',
  ),
  'b129a2cd-9e9f-412c-a754-901544175b9a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b129a2cd-9e9f-412c-a754-901544175b9a.webp',
  ),
  'c8b921a4-0c2b-448f-b1b6-d6d944793410': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c8b921a4-0c2b-448f-b1b6-d6d944793410.webp',
  ),
  '2b1b79b1-6e30-4b71-b42e-af7276430cc3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2b1b79b1-6e30-4b71-b42e-af7276430cc3.webp',
  ),
  'b5a8a7dc-9be4-4459-bc25-d4f08df7a23f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b5a8a7dc-9be4-4459-bc25-d4f08df7a23f.webp',
  ),
  'b50979b7-2f81-4594-a33c-a18248eb49bf': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b50979b7-2f81-4594-a33c-a18248eb49bf.webp',
  ),
  '0e1a706b-c872-43af-8b75-dc468dfbc1e9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0e1a706b-c872-43af-8b75-dc468dfbc1e9.webp',
  ),
  'd7237e28-2668-483f-933d-c9f9d6494858': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d7237e28-2668-483f-933d-c9f9d6494858.webp',
  ),
  '6b8bbe41-0b72-440d-9dee-d5740079270d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6b8bbe41-0b72-440d-9dee-d5740079270d.webp',
  ),
  '95d19606-2b98-4dd8-a89b-7af57f33f5bc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/95d19606-2b98-4dd8-a89b-7af57f33f5bc.webp',
  ),
  '31b05d84-c41e-45b1-b462-381ae7ff2e79': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/31b05d84-c41e-45b1-b462-381ae7ff2e79.webp',
  ),
  'c0022d52-1060-4366-93b0-1b6434760140': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c0022d52-1060-4366-93b0-1b6434760140.webp',
  ),
  'a55b2b1a-e7df-4fb5-8258-0d432803666c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a55b2b1a-e7df-4fb5-8258-0d432803666c.webp',
  ),
  '4248d7cf-7a76-41e2-aec8-921f803e951c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4248d7cf-7a76-41e2-aec8-921f803e951c.webp',
  ),
  'e7ea1afd-d808-42ac-a9d1-59ff2e3a55da': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e7ea1afd-d808-42ac-a9d1-59ff2e3a55da.webp',
  ),
  '56f03156-90a3-4d69-baa3-5e9a60f35dbb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/56f03156-90a3-4d69-baa3-5e9a60f35dbb.webp',
  ),
  '863382f5-9dd8-4d2f-8ab6-526878d0cb3d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/863382f5-9dd8-4d2f-8ab6-526878d0cb3d.webp',
  ),
  '2108ca80-a34d-43b2-b6d5-0f4960509214': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2108ca80-a34d-43b2-b6d5-0f4960509214.webp',
  ),
  '0b529620-69f1-4b11-ac06-acb22f616bbd': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0b529620-69f1-4b11-ac06-acb22f616bbd.webp',
  ),
  '89e61fef-2dd8-4f9b-8768-4aed08491ae8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/89e61fef-2dd8-4f9b-8768-4aed08491ae8.webp',
  ),
  '912ad2a0-2851-4c0e-864a-17dfbd0165f2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/912ad2a0-2851-4c0e-864a-17dfbd0165f2.webp',
  ),
  '66357519-2fe0-4e1f-b9ed-56f4e0107865': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/66357519-2fe0-4e1f-b9ed-56f4e0107865.webp',
  ),
  'ab998327-fd55-4e07-8b58-decafc29b0db': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ab998327-fd55-4e07-8b58-decafc29b0db.webp',
  ),
  'e038aaab-ddbc-4f03-a1d2-05ec0e438d3e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e038aaab-ddbc-4f03-a1d2-05ec0e438d3e.webp',
  ),
  '078292f9-3799-409c-ae6e-509ab3ac1475': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/078292f9-3799-409c-ae6e-509ab3ac1475.webp',
  ),
  '151646b6-751b-447f-baa5-87e5048320bf': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/151646b6-751b-447f-baa5-87e5048320bf.webp',
  ),
  'e51980b5-9ca9-46bc-ab67-d60be87b2708': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e51980b5-9ca9-46bc-ab67-d60be87b2708.webp',
  ),
  'f0bb6adf-81c9-405f-bd73-f6006f59da15': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f0bb6adf-81c9-405f-bd73-f6006f59da15.webp',
  ),
  '3c0747e5-9862-430b-a867-87f9e9a56db8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3c0747e5-9862-430b-a867-87f9e9a56db8.webp',
  ),
  '9ae2ef55-a2ba-4cc6-9f07-bdc5bfc9198f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9ae2ef55-a2ba-4cc6-9f07-bdc5bfc9198f.webp',
  ),
  'cf89f6c1-a22d-424d-8389-3dedfdf273a2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/cf89f6c1-a22d-424d-8389-3dedfdf273a2.webp',
  ),
  '1c3058a5-4f3c-40df-a1fc-9702b71aca3b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/1c3058a5-4f3c-40df-a1fc-9702b71aca3b.webp',
  ),
  '2f9b598b-ab0e-445a-9a3c-c90a7c401c01': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2f9b598b-ab0e-445a-9a3c-c90a7c401c01.webp',
  ),
  '63b1faeb-f72c-4d4e-b00f-80d089af71bb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/63b1faeb-f72c-4d4e-b00f-80d089af71bb.webp',
  ),
  'a57603aa-2b00-4fa2-bcd5-90177723b9a9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a57603aa-2b00-4fa2-bcd5-90177723b9a9.webp',
  ),
  'a8b4983a-10f9-47cc-b30a-3db5a37b5a0f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a8b4983a-10f9-47cc-b30a-3db5a37b5a0f.webp',
  ),
  '46514fa5-8a8e-4a5d-af99-8c76fccfdcb1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/46514fa5-8a8e-4a5d-af99-8c76fccfdcb1.webp',
  ),
  '4444ad68-b524-40a7-b51a-06dd2976bbcb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4444ad68-b524-40a7-b51a-06dd2976bbcb.webp',
  ),
  '208bda6f-eb8d-4bec-8ac0-33c661297436': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/208bda6f-eb8d-4bec-8ac0-33c661297436.webp',
  ),
  '35ad6771-6f9f-4145-b032-70191466c441': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/35ad6771-6f9f-4145-b032-70191466c441.webp',
  ),
  '0629267b-f3a0-4124-b219-7a0c54bcb986': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0629267b-f3a0-4124-b219-7a0c54bcb986.webp',
  ),
  '9f69e8dd-8da1-42e8-87ee-945acbb86fdd': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9f69e8dd-8da1-42e8-87ee-945acbb86fdd.webp',
  ),
  'd3b7ae7e-f21d-47c7-858b-4e78c8492540': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d3b7ae7e-f21d-47c7-858b-4e78c8492540.webp',
  ),
  '0dd361b9-776a-407c-bdcf-d5de515b111f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0dd361b9-776a-407c-bdcf-d5de515b111f.webp',
  ),
  'e99b3886-6813-42dd-bf5f-1e597a7dd8b8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e99b3886-6813-42dd-bf5f-1e597a7dd8b8.webp',
  ),
  '362282f4-2385-49e4-a4b9-fefdd78c2773': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/362282f4-2385-49e4-a4b9-fefdd78c2773.webp',
  ),
  '77f6e0e9-1795-4325-8936-80e345b74257': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/77f6e0e9-1795-4325-8936-80e345b74257.webp',
  ),
  '3a2bb9ad-65f9-485e-aaa7-4c45f6811834': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3a2bb9ad-65f9-485e-aaa7-4c45f6811834.webp',
  ),
  '3206cebf-6179-4f4c-8f5a-93c9a68dce72': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3206cebf-6179-4f4c-8f5a-93c9a68dce72.webp',
  ),
  '62942ed8-5bba-4466-acf4-21bc26f864b3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/62942ed8-5bba-4466-acf4-21bc26f864b3.webp',
  ),
  'a37045c2-b081-4b0c-bb95-eb77a3ee2780': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a37045c2-b081-4b0c-bb95-eb77a3ee2780.webp',
  ),
  '5e7771e7-6c9c-48c1-82b4-8031ac8b60e3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5e7771e7-6c9c-48c1-82b4-8031ac8b60e3.webp',
  ),
  '8d3c66eb-b5e6-4df9-887e-077c0ac371da': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8d3c66eb-b5e6-4df9-887e-077c0ac371da.webp',
  ),
  '3c2f7dfa-68ee-4fae-8804-f839e89e6dfe': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3c2f7dfa-68ee-4fae-8804-f839e89e6dfe.webp',
  ),
  'cf3086e8-5ec0-4a6f-b36c-f8e9701fdf36': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/cf3086e8-5ec0-4a6f-b36c-f8e9701fdf36.webp',
  ),
  'ffc2e8c2-dd9c-48cb-a067-70df475e20f7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ffc2e8c2-dd9c-48cb-a067-70df475e20f7.webp',
  ),
  '99e4f20c-1eca-4bb1-8b44-a92f0b4329a7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/99e4f20c-1eca-4bb1-8b44-a92f0b4329a7.webp',
  ),
  'b88bba08-bd78-4e2b-bff1-be5eabebc52e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b88bba08-bd78-4e2b-bff1-be5eabebc52e.webp',
  ),
  '9a19473e-7eb8-4dfd-9194-57cc1a16e888': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9a19473e-7eb8-4dfd-9194-57cc1a16e888.webp',
  ),
  '686ff7f6-1845-40ce-9304-b70bbd2ada65': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/686ff7f6-1845-40ce-9304-b70bbd2ada65.webp',
  ),
  '6e1219f5-3011-4c66-af27-1d0608ba133c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6e1219f5-3011-4c66-af27-1d0608ba133c.webp',
  ),
  '6389c895-1658-4693-8467-fe8ddb5814f5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6389c895-1658-4693-8467-fe8ddb5814f5.webp',
  ),
  '5e60f560-44f2-4f4f-944d-815d61ed3089': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5e60f560-44f2-4f4f-944d-815d61ed3089.webp',
  ),
  'eaec95e4-9cca-4069-b72f-90f9484d17eb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/eaec95e4-9cca-4069-b72f-90f9484d17eb.webp',
  ),
  '15062e13-a81d-4740-94c6-9d802c9f07d7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/15062e13-a81d-4740-94c6-9d802c9f07d7.webp',
  ),
  '0ec6aad0-8836-436c-9511-5850833dec7e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0ec6aad0-8836-436c-9511-5850833dec7e.webp',
  ),
  '958fedb6-f049-441f-9503-310ca7f4a4dd': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/958fedb6-f049-441f-9503-310ca7f4a4dd.webp',
  ),
  'f7aed666-a7b5-4576-8696-c6b410f0278a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f7aed666-a7b5-4576-8696-c6b410f0278a.webp',
  ),
  '9c6e9045-c3d4-4a4b-b0b6-33b88dbb0663': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9c6e9045-c3d4-4a4b-b0b6-33b88dbb0663.webp',
  ),
  '2a699940-1bb3-4862-873e-0bbc814e2e92': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2a699940-1bb3-4862-873e-0bbc814e2e92.webp',
  ),
  '215479e6-fb0d-4735-bc6a-e2ef5eb077d4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/215479e6-fb0d-4735-bc6a-e2ef5eb077d4.webp',
  ),
  '042676ed-1820-4ee6-a30d-9a7a907c7c90': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/042676ed-1820-4ee6-a30d-9a7a907c7c90.webp',
  ),
  'ad90707d-f93e-415e-943a-b85672fa23ec': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ad90707d-f93e-415e-943a-b85672fa23ec.webp',
  ),
  '055844d8-d086-48d6-9fe2-4aa37f3ee430': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/055844d8-d086-48d6-9fe2-4aa37f3ee430.webp',
  ),
  'ee6979d5-aa9d-4b75-aacc-d5ba8692cca8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ee6979d5-aa9d-4b75-aacc-d5ba8692cca8.webp',
  ),
  'cb4fded0-96b5-4109-95d0-a8041527a6a0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/cb4fded0-96b5-4109-95d0-a8041527a6a0.webp',
  ),
  '2f5c31b1-78d0-45fc-9cf1-0775a7ae7b4c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2f5c31b1-78d0-45fc-9cf1-0775a7ae7b4c.webp',
  ),
  '82d0cc29-1a57-484a-a180-eeda6a37e0ab': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/82d0cc29-1a57-484a-a180-eeda6a37e0ab.webp',
  ),
  '5e1c95e2-17b2-49e0-b257-273e31cba14e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5e1c95e2-17b2-49e0-b257-273e31cba14e.webp',
  ),
  'de3d55b3-33ee-436d-bf68-c1891b248afe': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/de3d55b3-33ee-436d-bf68-c1891b248afe.webp',
  ),
  'e16ebb64-a761-4c7e-a830-7ccc4a9cb367': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e16ebb64-a761-4c7e-a830-7ccc4a9cb367.webp',
  ),
  'c2c08680-3a8a-432d-964d-932a4aa89ade': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c2c08680-3a8a-432d-964d-932a4aa89ade.webp',
  ),
  '240276c4-0816-4eeb-816a-d9eb6232c3ed': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/240276c4-0816-4eeb-816a-d9eb6232c3ed.webp',
  ),
  'fc49190a-bba1-403c-9571-329ae931a662': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/fc49190a-bba1-403c-9571-329ae931a662.webp',
  ),
  '982d58a0-6245-41b3-8bd3-40ae5f453b21': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/982d58a0-6245-41b3-8bd3-40ae5f453b21.webp',
  ),
  '30db32fd-5c46-4f99-ac8c-abd87734d748': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/30db32fd-5c46-4f99-ac8c-abd87734d748.webp',
  ),
  '970c33ac-e99e-403e-b52c-1a970fb3c07b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/970c33ac-e99e-403e-b52c-1a970fb3c07b.webp',
  ),
  '8af6af84-fd20-49ce-b5d6-60890e6c8154': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8af6af84-fd20-49ce-b5d6-60890e6c8154.webp',
  ),
  '84d3bec6-c999-40b8-8568-d8a5777a609e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/84d3bec6-c999-40b8-8568-d8a5777a609e.webp',
  ),
  '3ce554ad-d54b-4a40-8717-044b024e07fc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3ce554ad-d54b-4a40-8717-044b024e07fc.webp',
  ),
  'a05abb3e-41c2-48a8-bfc4-c257a377aeaf': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a05abb3e-41c2-48a8-bfc4-c257a377aeaf.webp',
  ),
  'f33239e8-fbfa-4de3-a45e-26758754fcb5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f33239e8-fbfa-4de3-a45e-26758754fcb5.webp',
  ),
  'e6980a99-0937-457e-815f-4cd953bcaf8c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e6980a99-0937-457e-815f-4cd953bcaf8c.webp',
  ),
  '688c951f-6cc7-41e6-911c-22f97227757d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/688c951f-6cc7-41e6-911c-22f97227757d.webp',
  ),
  '398d7b39-91bb-4c71-b3f9-9e1721d39a6e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/398d7b39-91bb-4c71-b3f9-9e1721d39a6e.webp',
  ),
  '49393d78-8141-4fe8-a9e9-a8e1d775ff47': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/49393d78-8141-4fe8-a9e9-a8e1d775ff47.webp',
  ),
  '20363a9b-d379-4872-9e71-d1ec8990f332': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/20363a9b-d379-4872-9e71-d1ec8990f332.webp',
  ),
  '9c12f378-eb9e-4e05-9c38-00aefd1da693': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9c12f378-eb9e-4e05-9c38-00aefd1da693.webp',
  ),
  'de610412-aee6-46e3-9759-375b81e73496': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/de610412-aee6-46e3-9759-375b81e73496.webp',
  ),
  '550cbd1d-a4db-415a-879f-fde291fbd0bc': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/550cbd1d-a4db-415a-879f-fde291fbd0bc.webp',
  ),
  '2c497cdc-ed65-4232-a3bb-30daf8f8085d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2c497cdc-ed65-4232-a3bb-30daf8f8085d.webp',
  ),
  'fdb3fc0c-4fc5-4ad4-8b0c-b48159aea5f2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/fdb3fc0c-4fc5-4ad4-8b0c-b48159aea5f2.webp',
  ),
  '16b15846-8bb6-486d-be3b-cbc5ea49f277': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/16b15846-8bb6-486d-be3b-cbc5ea49f277.webp',
  ),
  '95cd4bba-a3cf-4a09-8c11-d43d1f637026': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/95cd4bba-a3cf-4a09-8c11-d43d1f637026.webp',
  ),
  '9048d99f-145c-4350-8a2c-8adcb67b3f88': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9048d99f-145c-4350-8a2c-8adcb67b3f88.webp',
  ),
  'c7227e3b-1cb6-4a1a-9dc5-12012ea75a58': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c7227e3b-1cb6-4a1a-9dc5-12012ea75a58.webp',
  ),
  '4d679a6c-0141-4c89-b637-1ae251a71e46': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4d679a6c-0141-4c89-b637-1ae251a71e46.webp',
  ),
  '56314d18-ffb9-4e0c-b309-1f4e8ae0bfab': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/56314d18-ffb9-4e0c-b309-1f4e8ae0bfab.webp',
  ),
  '46b9e7fc-a130-4c2b-8590-7c0142efe8ef': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/46b9e7fc-a130-4c2b-8590-7c0142efe8ef.webp',
  ),
  '0caad64d-69c5-4f52-83b8-7d17461191db': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0caad64d-69c5-4f52-83b8-7d17461191db.webp',
  ),
  'f848d2ed-4d87-4039-acd1-78ad88945c80': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f848d2ed-4d87-4039-acd1-78ad88945c80.webp',
  ),
  '1b4bd57f-52b6-49e2-9a13-f07c6c7f2a9f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/1b4bd57f-52b6-49e2-9a13-f07c6c7f2a9f.webp',
  ),
  'b1a4e9a7-21f7-47c4-b5c3-ae22b054f144': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b1a4e9a7-21f7-47c4-b5c3-ae22b054f144.webp',
  ),
  '0f1e4d96-d410-44fb-be2b-98d24bd08de6': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0f1e4d96-d410-44fb-be2b-98d24bd08de6.webp',
  ),
  'e8ccdf4c-c05e-4a4e-9dbe-c51fd2c0b965': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e8ccdf4c-c05e-4a4e-9dbe-c51fd2c0b965.webp',
  ),
  'd0139cb3-a609-4e0f-950e-6e3b96aff444': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d0139cb3-a609-4e0f-950e-6e3b96aff444.webp',
  ),
  'e298b4b5-7887-419c-914d-cf3dc3617d49': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e298b4b5-7887-419c-914d-cf3dc3617d49.webp',
  ),
  'c00a69c5-8169-49c7-9ceb-f79bc53b0905': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c00a69c5-8169-49c7-9ceb-f79bc53b0905.webp',
  ),
  '69fc3266-0968-40db-8880-c3300556e502': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/69fc3266-0968-40db-8880-c3300556e502.webp',
  ),
  '5d533bc1-86bd-473e-b7c0-fba71f36c6c8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5d533bc1-86bd-473e-b7c0-fba71f36c6c8.webp',
  ),
  '2c71401f-908b-415b-bd85-118f601d9172': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/2c71401f-908b-415b-bd85-118f601d9172.webp',
  ),
  'b43ebcab-405a-4c63-a570-5a485399d1d7': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b43ebcab-405a-4c63-a570-5a485399d1d7.webp',
  ),
  'f3adf777-9fd7-497b-8ae0-e229231999f8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f3adf777-9fd7-497b-8ae0-e229231999f8.webp',
  ),
  '18ef3003-6279-468f-a5cd-d168871a7e7a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/18ef3003-6279-468f-a5cd-d168871a7e7a.webp',
  ),
  'ebf49926-f060-4e04-b57f-2b85e688d37a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ebf49926-f060-4e04-b57f-2b85e688d37a.webp',
  ),
  '40fd996e-4da4-4e02-bd07-ca855ee86585': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/40fd996e-4da4-4e02-bd07-ca855ee86585.webp',
  ),
  '0311016a-5628-46f4-a9df-4b5b319afb0e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0311016a-5628-46f4-a9df-4b5b319afb0e.webp',
  ),
  '0828be13-92f2-4aed-9da0-e871b66b4abf': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0828be13-92f2-4aed-9da0-e871b66b4abf.webp',
  ),
  '6da55a17-6a12-4391-9460-150c8d5f9e62': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6da55a17-6a12-4391-9460-150c8d5f9e62.webp',
  ),
  '7b478788-9fd5-4a30-b9c6-88409aa29a7e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7b478788-9fd5-4a30-b9c6-88409aa29a7e.webp',
  ),
  '4942890f-4ba8-4f7e-a39d-3d8538010ff8': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4942890f-4ba8-4f7e-a39d-3d8538010ff8.webp',
  ),
  '26bfcf1c-a778-477f-92f8-17bcb360f23d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/26bfcf1c-a778-477f-92f8-17bcb360f23d.webp',
  ),
  'e2545fcd-9060-407a-8df5-9803bc7b77d0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/e2545fcd-9060-407a-8df5-9803bc7b77d0.webp',
  ),
  '96bcd91c-78f9-40b6-b7e2-11d8e11fb343': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/96bcd91c-78f9-40b6-b7e2-11d8e11fb343.webp',
  ),
  '552f1efc-c035-4b7b-802f-7cc32c731d77': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/552f1efc-c035-4b7b-802f-7cc32c731d77.webp',
  ),
  'feab3448-1976-4e76-846d-4588615a6634': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/feab3448-1976-4e76-846d-4588615a6634.webp',
  ),
  '3cb7dda4-9510-44c7-8509-d4dd27f565b4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3cb7dda4-9510-44c7-8509-d4dd27f565b4.webp',
  ),
  '11ef5872-cc00-4d5a-822a-35f5d487f974': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/11ef5872-cc00-4d5a-822a-35f5d487f974.webp',
  ),
  'c7a3bc07-7f5c-41e4-a88c-a6e3bf9a9453': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c7a3bc07-7f5c-41e4-a88c-a6e3bf9a9453.webp',
  ),
  '8ebe21cd-85e1-4f31-9437-96f2b9d7fc1c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/8ebe21cd-85e1-4f31-9437-96f2b9d7fc1c.webp',
  ),
  '6b580612-d381-4225-9ecc-2eabba0b0897': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6b580612-d381-4225-9ecc-2eabba0b0897.webp',
  ),
  '04564799-c5cc-4962-9bfd-8c6fde5f4020': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/04564799-c5cc-4962-9bfd-8c6fde5f4020.webp',
  ),
  '06d6d07b-3a8a-4d00-98d4-dccd6d958e55': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/06d6d07b-3a8a-4d00-98d4-dccd6d958e55.webp',
  ),
  '589b501a-bf0a-474a-860f-21bdf67dfbfb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/589b501a-bf0a-474a-860f-21bdf67dfbfb.webp',
  ),
  '5157a335-1217-4783-9744-a29bfaa67ade': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5157a335-1217-4783-9744-a29bfaa67ade.webp',
  ),
  '377f2a01-e696-4ad7-bf9b-3c2471ed015c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/377f2a01-e696-4ad7-bf9b-3c2471ed015c.webp',
  ),
  '4c1a0f7c-f2dd-49dd-9923-57fd0b95088c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4c1a0f7c-f2dd-49dd-9923-57fd0b95088c.webp',
  ),
  'aa26ef48-b473-43e6-ad0e-defa11df126d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/aa26ef48-b473-43e6-ad0e-defa11df126d.webp',
  ),
  'f0ca46e3-1194-4204-8865-387dbfb3da3e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f0ca46e3-1194-4204-8865-387dbfb3da3e.webp',
  ),
  'd52d0c28-7b66-4286-b3f6-488f7b4509d9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d52d0c28-7b66-4286-b3f6-488f7b4509d9.webp',
  ),
  'fbd02086-13ba-4bd4-9240-856acee664b4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/fbd02086-13ba-4bd4-9240-856acee664b4.webp',
  ),
  '7aa4355d-6294-491b-98db-e0c93d349dd4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7aa4355d-6294-491b-98db-e0c93d349dd4.webp',
  ),
  '7790ef99-c1ed-410b-96dd-9ed3852e869f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/7790ef99-c1ed-410b-96dd-9ed3852e869f.webp',
  ),
  '25c4362d-159d-4732-8a17-602cddc64961': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/25c4362d-159d-4732-8a17-602cddc64961.webp',
  ),
  'd9f2b354-40f5-40b4-9700-d0bf2d80262b': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d9f2b354-40f5-40b4-9700-d0bf2d80262b.webp',
  ),
  '0f088283-24e5-493e-abc8-3a4b568b80b9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0f088283-24e5-493e-abc8-3a4b568b80b9.webp',
  ),
  '03c451ed-d7b0-49f9-af3a-f488b7aa2b3e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/03c451ed-d7b0-49f9-af3a-f488b7aa2b3e.webp',
  ),
  '6768eea4-c769-4b50-9e4e-0c689ccf1689': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/6768eea4-c769-4b50-9e4e-0c689ccf1689.webp',
  ),
  '9821517a-c9c6-477a-8010-9a6039e0cd76': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9821517a-c9c6-477a-8010-9a6039e0cd76.webp',
  ),
  '217ff03b-60a4-4cc4-8f8a-008331733b97': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/217ff03b-60a4-4cc4-8f8a-008331733b97.webp',
  ),
  '3dc4958b-95dd-4f9f-8ff7-3fc5106950a0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3dc4958b-95dd-4f9f-8ff7-3fc5106950a0.webp',
  ),
  '5a1f0053-b332-482e-91eb-83a73444b822': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5a1f0053-b332-482e-91eb-83a73444b822.webp',
  ),
  'd22df6fc-da6f-4994-89ce-4553dc0f65f2': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d22df6fc-da6f-4994-89ce-4553dc0f65f2.webp',
  ),
  '39946b4b-df7d-460b-bb4e-84e3c488c755': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/39946b4b-df7d-460b-bb4e-84e3c488c755.webp',
  ),
  'c47bfbd5-0732-4505-bfaa-613f317923ce': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/c47bfbd5-0732-4505-bfaa-613f317923ce.webp',
  ),
  'b9ddf0ba-8ab8-4340-85a9-f92921ebebd0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b9ddf0ba-8ab8-4340-85a9-f92921ebebd0.webp',
  ),
  '90c2940e-bcf4-4b59-a77d-8c3087b04e22': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/90c2940e-bcf4-4b59-a77d-8c3087b04e22.webp',
  ),
  '4d976e57-12b6-4085-b47c-84f501253b9c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4d976e57-12b6-4085-b47c-84f501253b9c.webp',
  ),
  'f2aa53ed-eb39-4f65-8443-d3af0e66d275': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/f2aa53ed-eb39-4f65-8443-d3af0e66d275.webp',
  ),
  'caaa25f3-7fec-4461-ae66-98848e9c3c9e': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/caaa25f3-7fec-4461-ae66-98848e9c3c9e.webp',
  ),
  '3e66e1df-03df-49c7-ad1c-574ad80e7591': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3e66e1df-03df-49c7-ad1c-574ad80e7591.webp',
  ),
  '06b662a1-ff3f-4d91-94ed-27f46abdc39a': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/06b662a1-ff3f-4d91-94ed-27f46abdc39a.webp',
  ),
  'cab6604b-9db5-44d6-a884-e99566dfaf26': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/cab6604b-9db5-44d6-a884-e99566dfaf26.webp',
  ),
  '82dbea5a-e85a-42f9-a130-72784b593afe': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/82dbea5a-e85a-42f9-a130-72784b593afe.webp',
  ),
  'b92038ff-4fe6-4a00-8a18-7fb3f161fd4d': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b92038ff-4fe6-4a00-8a18-7fb3f161fd4d.webp',
  ),
  'd9187c0d-df0d-43a7-b485-be3ffa10f3eb': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/d9187c0d-df0d-43a7-b485-be3ffa10f3eb.webp',
  ),
  'b84f3317-da55-44ac-8822-6c7011257f21': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b84f3317-da55-44ac-8822-6c7011257f21.webp',
  ),
  '1f9cf866-25c6-4106-9d05-dfcd89cbc4ad': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/1f9cf866-25c6-4106-9d05-dfcd89cbc4ad.webp',
  ),
  'b93d80cd-0ac6-4d78-81f1-d6a10adee82f': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/b93d80cd-0ac6-4d78-81f1-d6a10adee82f.webp',
  ),
  'a035b305-56ed-4d7b-9061-3987eccdf7f0': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a035b305-56ed-4d7b-9061-3987eccdf7f0.webp',
  ),
  'ebdaadfa-082c-4dd2-ad29-9025b431e181': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/ebdaadfa-082c-4dd2-ad29-9025b431e181.webp',
  ),
  'acadee82-15f1-4166-9429-55dbb49953b5': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/acadee82-15f1-4166-9429-55dbb49953b5.webp',
  ),
  '5a1743a2-e672-4749-adf9-1ee74a12f20c': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/5a1743a2-e672-4749-adf9-1ee74a12f20c.webp',
  ),
  '0d00864d-3cf8-41fc-9953-6f6a100115a3': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/0d00864d-3cf8-41fc-9953-6f6a100115a3.webp',
  ),
  '9cc590df-dc2c-4df7-bafa-8db48c1c5571': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/9cc590df-dc2c-4df7-bafa-8db48c1c5571.webp',
  ),
  '3449ca54-8d74-4d37-9a9f-c369f1bc29b9': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3449ca54-8d74-4d37-9a9f-c369f1bc29b9.webp',
  ),
  'a9328f6f-476b-464d-873c-8828dcf5d6b1': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/a9328f6f-476b-464d-873c-8828dcf5d6b1.webp',
  ),
  '4315fcda-cf8a-487b-b63d-85f263ba6ae4': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/4315fcda-cf8a-487b-b63d-85f263ba6ae4.webp',
  ),
  '98f9a6c2-df94-43f4-9a18-b6fa90348aaa': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/98f9a6c2-df94-43f4-9a18-b6fa90348aaa.webp',
  ),
  '3d46e28e-617a-4d80-b390-6f18a6426e04': ExerciseMedia(
    imageAsset:
        'assets/exercises/images/3d46e28e-617a-4d80-b390-6f18a6426e04.webp',
  ),
};
