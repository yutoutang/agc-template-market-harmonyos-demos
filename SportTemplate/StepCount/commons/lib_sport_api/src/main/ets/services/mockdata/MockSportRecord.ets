import { ChildSportType, SportRecord, SportType, TargetType } from '../../database/SportRecord';
import { mapCommon } from '@kit.MapKit';

export class MockSportRecord {
  static genEmptyRecord(year: number, month: number, day: number): SportRecord {
    return {
      year: year,
      month: month,
      day: day,
      totalTarget: null,
      totalDistance: 0,
      totalDeplete: 0,
      totalSportTimeLength: 0,
      totalStepCount: 0,
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: []
    }
  }

  static dummyLocusPoints: mapCommon.LatLng[] = [
    { 'latitude': 31.21753369730675, 'longitude': 121.46433714831034 },
    { 'latitude': 31.21590040793165, 'longitude': 121.46472361019308 },
    { 'latitude': 31.215243024145828, 'longitude': 121.46496376898192 },
    { 'latitude': 31.214935159573496, 'longitude': 121.46518072232607 },
    { 'latitude': 31.21510009630906, 'longitude': 121.46569765239163 },
    { 'latitude': 31.215277890436568, 'longitude': 121.4672965168454 },
    { 'latitude': 31.21567502824727, 'longitude': 121.46920907143154 },
    { 'latitude': 31.215747386551435, 'longitude': 121.47022939750309 },
    { 'latitude': 31.215561705534878, 'longitude': 121.47061979395215 },
    { 'latitude': 31.215669713797265, 'longitude': 121.47102805617392 },
    { 'latitude': 31.215584466336516, 'longitude': 121.47184772903086 },
    { 'latitude': 31.215842175206387, 'longitude': 121.47258616327812 },
    { 'latitude': 31.215865904815765, 'longitude': 121.47315439333182 },
    { 'latitude': 31.216199600623764, 'longitude': 121.4746214027384 },
    { 'latitude': 31.216088242917422, 'longitude': 121.47477410867172 },
    { 'latitude': 31.215493400610814, 'longitude': 121.47506034748247 },
    { 'latitude': 31.215165741445634, 'longitude': 121.47506181456565 },
    { 'latitude': 31.21406376485807, 'longitude': 121.4753447179717 },
    { 'latitude': 31.21358811556205, 'longitude': 121.47557813139609 },
    { 'latitude': 31.212927499719594, 'longitude': 121.47565353328258 },
    { 'latitude': 31.212221999387943, 'longitude': 121.47552797399845 },
    { 'latitude': 31.211635458395364, 'longitude': 121.4758498931255 },
    { 'latitude': 31.210253090295115, 'longitude': 121.47603926656119 },
    { 'latitude': 31.209236836353007, 'longitude': 121.47662190391347 },
    { 'latitude': 31.20823063335413, 'longitude': 121.47688875535269 },
    { 'latitude': 31.207632987867797, 'longitude': 121.47727973761175 },
    { 'latitude': 31.206667508089943, 'longitude': 121.47732231632543 },
    { 'latitude': 31.206179907784474, 'longitude': 121.47749381742636 },
    { 'latitude': 31.2058817591866, 'longitude': 121.47764280731279 },
    { 'latitude': 31.205637422374185, 'longitude': 121.47790692605908 },
    { 'latitude': 31.20499559462231, 'longitude': 121.47813353131957 },
    { 'latitude': 31.20462138170559, 'longitude': 121.47843800342874 },
    { 'latitude': 31.204069978428645, 'longitude': 121.47768182436643 },
    { 'latitude': 31.203648983744703, 'longitude': 121.47642226612072 },
    { 'latitude': 31.203477242044748, 'longitude': 121.47562421276821 },
    { 'latitude': 31.2031976125684, 'longitude': 121.47535993299347 },
    { 'latitude': 31.20316439898117, 'longitude': 121.47517143114814 },
    { 'latitude': 31.202230476051852, 'longitude': 121.47523534700365 },
    { 'latitude': 31.201050985727598, 'longitude': 121.47557914785658 },
    { 'latitude': 31.200262370789076, 'longitude': 121.47600162669931 },
    { 'latitude': 31.199477028986927, 'longitude': 121.4761727096627 },
    { 'latitude': 31.19934088486739, 'longitude': 121.47608996375845 },
    { 'latitude': 31.199108883622955, 'longitude': 121.47454816165185 },
    { 'latitude': 31.198683020443738, 'longitude': 121.47316338338265 },
    { 'latitude': 31.198498563869066, 'longitude': 121.47280578369411 },
    { 'latitude': 31.198393356324566, 'longitude': 121.47221162063511 },
    { 'latitude': 31.197782408251285, 'longitude': 121.47012446502661 },
    { 'latitude': 31.19771152830976, 'longitude': 121.4695886785084 },
    { 'latitude': 31.197298473768033, 'longitude': 121.46913241461355 },
    { 'latitude': 31.196998745895794, 'longitude': 121.46924445253957 },
    { 'latitude': 31.19663121835187, 'longitude': 121.46958130748429 },
    { 'latitude': 31.195811522355527, 'longitude': 121.46969798487879 },
    { 'latitude': 31.19512396038663, 'longitude': 121.46966811566048 },
    { 'latitude': 31.194281806351462, 'longitude': 121.46864800297674 },
    { 'latitude': 31.194079847627968, 'longitude': 121.46782632484789 },
    { 'latitude': 31.193797924414163, 'longitude': 121.46741451435089 },
    { 'latitude': 31.19365246357126, 'longitude': 121.4674507950841 },
    { 'latitude': 31.19349683260857, 'longitude': 121.46669748779777 },
    { 'latitude': 31.193218320730356, 'longitude': 121.46611106734693 },
    { 'latitude': 31.1926436945358, 'longitude': 121.46534063723674 },
    { 'latitude': 31.192545738232617, 'longitude': 121.46526055824613 },
    { 'latitude': 31.19242396703299, 'longitude': 121.46543195628495 },
    { 'latitude': 31.19231774322869, 'longitude': 121.4650024765179 },
    { 'latitude': 31.191925397315206, 'longitude': 121.46435179241578 },
    { 'latitude': 31.19092460920295, 'longitude': 121.46315765987764 },
    { 'latitude': 31.18949515263384, 'longitude': 121.4608694119127 },
    { 'latitude': 31.189205735692838, 'longitude': 121.46054685514126 },
    { 'latitude': 31.188622979571996, 'longitude': 121.45941003191092 },
    { 'latitude': 31.187667673566306, 'longitude': 121.45786687496827 },
    { 'latitude': 31.187282420825234, 'longitude': 121.45696115881154 },
    { 'latitude': 31.18693286971141, 'longitude': 121.4551827781417 },
    { 'latitude': 31.186764138005238, 'longitude': 121.45471900175164 },
    { 'latitude': 31.18675844620367, 'longitude': 121.45417302931376 },
    { 'latitude': 31.186204550279808, 'longitude': 121.45268134341349 },
    { 'latitude': 31.185814625342495, 'longitude': 121.45136058128155 },
    { 'latitude': 31.185310727946547, 'longitude': 121.4503327736328 },
    { 'latitude': 31.184754044589425, 'longitude': 121.44947783183126 },
    { 'latitude': 31.18125212363581, 'longitude': 121.44532849730038 },
    { 'latitude': 31.180741032751204, 'longitude': 121.44432754590942 },
    { 'latitude': 31.180220001173975, 'longitude': 121.44375761381042 },
    { 'latitude': 31.179947443184872, 'longitude': 121.44327392244828 },
    { 'latitude': 31.179528223767033, 'longitude': 121.44283951361929 },
    { 'latitude': 31.17920858781024, 'longitude': 121.44218641263257 },
    { 'latitude': 31.178308465672483, 'longitude': 121.4410565071458 },
    { 'latitude': 31.178106101443312, 'longitude': 121.44063125324173 },
    { 'latitude': 31.178151717403843, 'longitude': 121.4401633869812 },
    { 'latitude': 31.179350879638065, 'longitude': 121.43852191554795 },
    { 'latitude': 31.179310504915552, 'longitude': 121.43848936667236 },
    { 'latitude': 31.179426218389647, 'longitude': 121.43852132308862 },
    { 'latitude': 31.179326438433336, 'longitude': 121.43832793821744 },
    { 'latitude': 31.180596578357235, 'longitude': 121.4361746255987 },
    { 'latitude': 31.181211809325887, 'longitude': 121.43383748374674 },
    { 'latitude': 31.181492263968384, 'longitude': 121.43357448482432 },
    { 'latitude': 31.18190273513973, 'longitude': 121.43292233906887 },
    { 'latitude': 31.182501577449287, 'longitude': 121.43218550231299 },
    { 'latitude': 31.183380768594617, 'longitude': 121.4313270210742 },
    { 'latitude': 31.184042509663442, 'longitude': 121.43047637237807 },
    { 'latitude': 31.184785187039378, 'longitude': 121.42969630650909 },
    { 'latitude': 31.18543659775472, 'longitude': 121.42870504886561 },
    { 'latitude': 31.186910399726877, 'longitude': 121.42768564221663 },
    { 'latitude': 31.187890722269387, 'longitude': 121.42676383362159 },
    { 'latitude': 31.188290749050232, 'longitude': 121.42650444339858 },
    { 'latitude': 31.188667035378465, 'longitude': 121.42639009622053 },
    { 'latitude': 31.18947177156394, 'longitude': 121.42564203462399 },
    { 'latitude': 31.1902134811347, 'longitude': 121.42510453285624 },
    { 'latitude': 31.190547335493076, 'longitude': 121.42499416958472 },
    { 'latitude': 31.190682002045484, 'longitude': 121.42486970195775 },
    { 'latitude': 31.19125380930153, 'longitude': 121.42545397819026 },
    { 'latitude': 31.192051032148754, 'longitude': 121.42647869773867 },
    { 'latitude': 31.192303224485244, 'longitude': 121.42651538106823 },
    { 'latitude': 31.19243426568308, 'longitude': 121.42642758478402 },
    { 'latitude': 31.19298578102905, 'longitude': 121.42481695336086 },
    { 'latitude': 31.193223854691407, 'longitude': 121.42423542519364 },
    { 'latitude': 31.1933712463656, 'longitude': 121.42408038190669 },
    { 'latitude': 31.19360693157388, 'longitude': 121.42290295315773 },
    { 'latitude': 31.19373256361858, 'longitude': 121.4228039490654 },
    { 'latitude': 31.19455018674478, 'longitude': 121.42248798791186 },
    { 'latitude': 31.195255628438264, 'longitude': 121.42234976474326 },
    { 'latitude': 31.19636810777566, 'longitude': 121.42185536604957 },
    { 'latitude': 31.196546703449233, 'longitude': 121.42184299155443 },
    { 'latitude': 31.196692765764965, 'longitude': 121.42200657200904 },
    { 'latitude': 31.196815943116913, 'longitude': 121.42183112453554 },
    { 'latitude': 31.197266960263814, 'longitude': 121.42153180192089 },
    { 'latitude': 31.19821567241377, 'longitude': 121.42161072220954 },
    { 'latitude': 31.198566843484954, 'longitude': 121.42130179481835 },
    { 'latitude': 31.19872591501294, 'longitude': 121.42131130129776 },
    { 'latitude': 31.199082805033083, 'longitude': 121.42096959430596 },
    { 'latitude': 31.19944200665227, 'longitude': 121.42076537913685 },
    { 'latitude': 31.200466493744358, 'longitude': 121.42045559701415 },
    { 'latitude': 31.201047372693413, 'longitude': 121.41995270785621 },
    { 'latitude': 31.201719214734492, 'longitude': 121.41975090711965 },
    { 'latitude': 31.20254018427419, 'longitude': 121.41962486542387 },
    { 'latitude': 31.203119574219564, 'longitude': 121.41924777051128 },
    { 'latitude': 31.203499879964152, 'longitude': 121.41920803002397 },
    { 'latitude': 31.205290645842556, 'longitude': 121.41804931826402 },
    { 'latitude': 31.20618302159874, 'longitude': 121.41774927389054 },
    { 'latitude': 31.20747226998179, 'longitude': 121.41747794291665 },
    { 'latitude': 31.20785970701261, 'longitude': 121.41714916129364 },
    { 'latitude': 31.208023988216944, 'longitude': 121.41714397846843 },
    { 'latitude': 31.208299715455844, 'longitude': 121.4173740739487 },
    { 'latitude': 31.20869736516469, 'longitude': 121.41746245846134 },
    { 'latitude': 31.211008219898204, 'longitude': 121.41757099764577 },
    { 'latitude': 31.212445346738974, 'longitude': 121.41790222934827 },
    { 'latitude': 31.212944984130072, 'longitude': 121.41810705028446 },
    { 'latitude': 31.21358164859283, 'longitude': 121.41798158112196 },
    { 'latitude': 31.21565925088913, 'longitude': 121.41731324939661 },
    { 'latitude': 31.21644624159939, 'longitude': 121.41748941821761 },
    { 'latitude': 31.21694659648271, 'longitude': 121.41744978440596 },
    { 'latitude': 31.217338025799165, 'longitude': 121.41777872850149 },
    { 'latitude': 31.217675919812983, 'longitude': 121.4177064002236 },
    { 'latitude': 31.21781134410573, 'longitude': 121.41778906368374 },
    { 'latitude': 31.21817498719965, 'longitude': 121.41825401665345 },
    { 'latitude': 31.218734871618516, 'longitude': 121.41971201633643 },
    { 'latitude': 31.218667426604465, 'longitude': 121.41991007274281 },
    { 'latitude': 31.21878603211058, 'longitude': 121.4205040574511 },
    { 'latitude': 31.2186601186152, 'longitude': 121.42107891655041 },
    { 'latitude': 31.21874815376213, 'longitude': 121.42108891658637 },
    { 'latitude': 31.21870981159175, 'longitude': 121.42159452020388 },
    { 'latitude': 31.219313525477638, 'longitude': 121.42185296661346 },
    { 'latitude': 31.219947140096437, 'longitude': 121.42312745267073 },
    { 'latitude': 31.220531070629445, 'longitude': 121.42399562546683 },
    { 'latitude': 31.220818559972674, 'longitude': 121.42418577471835 },
    { 'latitude': 31.2211339831645, 'longitude': 121.42485456852877 },
    { 'latitude': 31.221952778999498, 'longitude': 121.42557483072129 },
    { 'latitude': 31.222457816556332, 'longitude': 121.42616477326715 },
    { 'latitude': 31.22262792911331, 'longitude': 121.42658754565589 },
    { 'latitude': 31.223068375442416, 'longitude': 121.42688097136758 },
    { 'latitude': 31.224005557907407, 'longitude': 121.42792550285009 },
    { 'latitude': 31.223309091343747, 'longitude': 121.42890720839877 },
    { 'latitude': 31.223421224878965, 'longitude': 121.42922973454687 },
    { 'latitude': 31.224208361464033, 'longitude': 121.43004880419264 },
    { 'latitude': 31.224514544683146, 'longitude': 121.43077331776823 },
    { 'latitude': 31.224486728016405, 'longitude': 121.431149730054 },
    { 'latitude': 31.223985549620664, 'longitude': 121.43155795168653 },
    { 'latitude': 31.224005865582075, 'longitude': 121.43173342093073 },
    { 'latitude': 31.223797329789512, 'longitude': 121.43221545569183 },
    { 'latitude': 31.223505958344173, 'longitude': 121.43242344735576 },
    { 'latitude': 31.22270651059635, 'longitude': 121.43275072791197 },
    { 'latitude': 31.222638739476196, 'longitude': 121.43287155453169 },
    { 'latitude': 31.222773853245464, 'longitude': 121.43367982638503 },
    { 'latitude': 31.223182387836054, 'longitude': 121.43503527421457 },
    { 'latitude': 31.22328550126957, 'longitude': 121.43561650173532 },
    { 'latitude': 31.223211985393057, 'longitude': 121.43575837753176 },
    { 'latitude': 31.222458184451984, 'longitude': 121.43595171343797 },
    { 'latitude': 31.222047822233776, 'longitude': 121.43592871332109 },
    { 'latitude': 31.221557306370364, 'longitude': 121.43607274718609 },
    { 'latitude': 31.22096646302087, 'longitude': 121.4361240159646 },
    { 'latitude': 31.219174437238728, 'longitude': 121.43679739951709 },
    { 'latitude': 31.2183128621834, 'longitude': 121.4373716019527 },
    { 'latitude': 31.21793163458443, 'longitude': 121.43748079143737 },
    { 'latitude': 31.2176261997715, 'longitude': 121.43740019581377 },
    { 'latitude': 31.21743646292512, 'longitude': 121.43758238280294 },
    { 'latitude': 31.217016419597545, 'longitude': 121.4377618525226 },
    { 'latitude': 31.215946242956154, 'longitude': 121.43853457605736 },
    { 'latitude': 31.21594542481518, 'longitude': 121.43868951502236 },
    { 'latitude': 31.215684078612043, 'longitude': 121.43898808598138 },
    { 'latitude': 31.215491388240356, 'longitude': 121.43898747026631 },
    { 'latitude': 31.214850286390483, 'longitude': 121.4392663375518 },
    { 'latitude': 31.214509407961835, 'longitude': 121.43913822748794 },
    { 'latitude': 31.21494722508151, 'longitude': 121.441039222596 },
    { 'latitude': 31.21507690241498, 'longitude': 121.44207493674884 },
    { 'latitude': 31.21535294517033, 'longitude': 121.44308515932988 },
    { 'latitude': 31.215537316463877, 'longitude': 121.44433086200036 },
    { 'latitude': 31.21500058783691, 'longitude': 121.44485926889826 },
    { 'latitude': 31.21467998308943, 'longitude': 121.44501073858167 },
    { 'latitude': 31.21447767245297, 'longitude': 121.44501950346357 },
    { 'latitude': 31.214048086180966, 'longitude': 121.44542564953063 },
    { 'latitude': 31.213064368975207, 'longitude': 121.44580868666847 },
    { 'latitude': 31.212943909582975, 'longitude': 121.44592713439076 },
    { 'latitude': 31.21245112536508, 'longitude': 121.44607299288477 },
    { 'latitude': 31.211518752014143, 'longitude': 121.44655382007392 },
    { 'latitude': 31.211323301494122, 'longitude': 121.44652915423981 },
    { 'latitude': 31.210740711534832, 'longitude': 121.44670873061236 },
    { 'latitude': 31.21063076450425, 'longitude': 121.44682038835575 },
    { 'latitude': 31.210558162775843, 'longitude': 121.44720118400139 },
    { 'latitude': 31.21050924626314, 'longitude': 121.4478182719951 },
    { 'latitude': 31.21062459872831, 'longitude': 121.44865308447245 },
    { 'latitude': 31.21058616967015, 'longitude': 121.44942339376544 },
    { 'latitude': 31.210672492073943, 'longitude': 121.44997208266969 },
    { 'latitude': 31.210917335053725, 'longitude': 121.45096546270229 },
    { 'latitude': 31.211718710065245, 'longitude': 121.45342858346461 },
    { 'latitude': 31.211824009265992, 'longitude': 121.45419953808874 },
    { 'latitude': 31.212522794151855, 'longitude': 121.4566383632393 },
    { 'latitude': 31.212615658343655, 'longitude': 121.45719416054497 },
    { 'latitude': 31.212743106411192, 'longitude': 121.45724693696086 },
    { 'latitude': 31.213555579936628, 'longitude': 121.45706537006325 },
    { 'latitude': 31.214215759035135, 'longitude': 121.45703460554697 },
    { 'latitude': 31.21458305190699, 'longitude': 121.45819017077308 },
    { 'latitude': 31.214836447042153, 'longitude': 121.45843196501765 },
    { 'latitude': 31.215151137745412, 'longitude': 121.45964241410361 },
    { 'latitude': 31.215413871495194, 'longitude': 121.46008785244916 },
    { 'latitude': 31.21596162507062, 'longitude': 121.46146548701203 },
    { 'latitude': 31.216114491408824, 'longitude': 121.46177485624658 },
    { 'latitude': 31.216410748184806, 'longitude': 121.4618986431485 },
    { 'latitude': 31.21656996586696, 'longitude': 121.46222855124152 },
    { 'latitude': 31.216986945279913, 'longitude': 121.46258290986701 },
    { 'latitude': 31.21742361971394, 'longitude': 121.46354147960479 },
    { 'latitude': 31.217622250662227, 'longitude': 121.46416314801242 },
    { 'latitude': 31.217228647331016, 'longitude': 121.46429743432084 },
    { 'latitude': 31.217312489299246, 'longitude': 121.46425416397577 }
  ]
  static dummyLocusPoints1: mapCommon.LatLng[] = [{ 'latitude': 31.228688162001184, 'longitude': 121.46230130020149 },
    { 'latitude': 31.227706925457436, 'longitude': 121.4626402792434 },
    { 'latitude': 31.226875800334444, 'longitude': 121.46295932234807 },
    { 'latitude': 31.226866212717155, 'longitude': 121.46277981987846 },
    { 'latitude': 31.226937994613248, 'longitude': 121.46202191674675 },
    { 'latitude': 31.22693958961756, 'longitude': 121.46132382298215 },
    { 'latitude': 31.226682589074272, 'longitude': 121.45993752931486 },
    { 'latitude': 31.226514254996076, 'longitude': 121.45914959985993 },
    { 'latitude': 31.226226255642644, 'longitude': 121.45817212668796 },
    { 'latitude': 31.226106933087618, 'longitude': 121.45783299254559 },
    { 'latitude': 31.225987413918567, 'longitude': 121.45758362343538 },
    { 'latitude': 31.225499078835487, 'longitude': 121.45669584302226 },
    { 'latitude': 31.225339552130364, 'longitude': 121.45643648376586 },
    { 'latitude': 31.223838115840834, 'longitude': 121.45678547211818 },
    { 'latitude': 31.223267638299514, 'longitude': 121.45688516990612 },
    { 'latitude': 31.222827390444717, 'longitude': 121.4569050812048 },
    { 'latitude': 31.222827390444717, 'longitude': 121.4569050812048 },
    { 'latitude': 31.222147093702592, 'longitude': 121.45689504767932 },
    { 'latitude': 31.221916922520613, 'longitude': 121.4569249518193 },
    { 'latitude': 31.221526485380416, 'longitude': 121.4570446138679 },
    { 'latitude': 31.221195926725038, 'longitude': 121.45723410243716 },
    { 'latitude': 31.22097543966582, 'longitude': 121.45741362456394 },
    { 'latitude': 31.220624954707926, 'longitude': 121.45756321089922 },
    { 'latitude': 31.22011437226738, 'longitude': 121.4577227568181 },
    { 'latitude': 31.2186626775936, 'longitude': 121.45819142107966 },
    { 'latitude': 31.218482441329183, 'longitude': 121.45826122448155 },
    { 'latitude': 31.218174762572335, 'longitude': 121.4571141463078 },
    { 'latitude': 31.217747210382417, 'longitude': 121.45585727685237 },
    { 'latitude': 31.217597638145637, 'longitude': 121.45561785969305 },
    { 'latitude': 31.216822597381764, 'longitude': 121.4529941598149 },
    { 'latitude': 31.21674291498786, 'longitude': 121.45281457771958 },
    { 'latitude': 31.21681373359147, 'longitude': 121.45241552275372 },
    { 'latitude': 31.216894064435774, 'longitude': 121.45226587997763 },
    { 'latitude': 31.21708508630015, 'longitude': 121.45178701067856 },
    { 'latitude': 31.21717534120202, 'longitude': 121.45167727238075 },
    { 'latitude': 31.216936606850272, 'longitude': 121.45095890015088 },
    { 'latitude': 31.216499097991246, 'longitude': 121.44952208900781 },
    { 'latitude': 31.216111029923876, 'longitude': 121.44836458584405 },
    { 'latitude': 31.216111029923876, 'longitude': 121.44836458584405 },
    { 'latitude': 31.216081195734553, 'longitude': 121.44826479849618 },
    { 'latitude': 31.215922687220996, 'longitude': 121.447386658813 },
    { 'latitude': 31.215883055341752, 'longitude': 121.44716711824543 },
    { 'latitude': 31.21574312933439, 'longitude': 121.44708727386775 },
    { 'latitude': 31.215192535210416, 'longitude': 121.44727682723142 },
    { 'latitude': 31.2151525514293, 'longitude': 121.44725686583443 },
    { 'latitude': 31.214983379949285, 'longitude': 121.44673793838301 },
    { 'latitude': 31.21474307470143, 'longitude': 121.44684768862012 },
    { 'latitude': 31.21451414122509, 'longitude': 121.44616907482445 },
    { 'latitude': 31.214374961389804, 'longitude': 121.44565012321236 },
    { 'latitude': 31.213888551775213, 'longitude': 121.44333465471979 },
    { 'latitude': 31.213888551775213, 'longitude': 121.44333465471979 },
    { 'latitude': 31.213541016816595, 'longitude': 121.44165777369939 },
    { 'latitude': 31.213242682191876, 'longitude': 121.44045991223541 },
    { 'latitude': 31.213162969091037, 'longitude': 121.44024029438738 },
    { 'latitude': 31.213073205282292, 'longitude': 121.44005062067328 },
    { 'latitude': 31.212942923269186, 'longitude': 121.44020034576457 },
    { 'latitude': 31.212231919032334, 'longitude': 121.44064948653646 },
    { 'latitude': 31.212231919032334, 'longitude': 121.44064948653646 },
    { 'latitude': 31.211851379164244, 'longitude': 121.44088902406176 },
    { 'latitude': 31.211601109741984, 'longitude': 121.44098882256233 },
    { 'latitude': 31.211350900134608, 'longitude': 121.44104869274145 },
    { 'latitude': 31.210940674224833, 'longitude': 121.44106862106034 },
    { 'latitude': 31.210770638202646, 'longitude': 121.44103866040412 },
    { 'latitude': 31.208290464917273, 'longitude': 121.44035965947772 },
    { 'latitude': 31.207200543515274, 'longitude': 121.43995028594058 },
    { 'latitude': 31.204451861114347, 'longitude': 121.43809321286868 },
    { 'latitude': 31.204321894904812, 'longitude': 121.43802331731987 },
    { 'latitude': 31.204321894904812, 'longitude': 121.43802331731987 },
    { 'latitude': 31.204181937393564, 'longitude': 121.43794343713395 },
    { 'latitude': 31.20395190862265, 'longitude': 121.43788351592305 },
    { 'latitude': 31.20137841214331, 'longitude': 121.43948059683274 },
    { 'latitude': 31.199345799360803, 'longitude': 121.44058847505734 },
    { 'latitude': 31.19996276075549, 'longitude': 121.44276453051033 },
    { 'latitude': 31.200022267176557, 'longitude': 121.44309391015459 },
    { 'latitude': 31.200051914772725, 'longitude': 121.44332347362563 },
    { 'latitude': 31.200479060230112, 'longitude': 121.44518984569 },
    { 'latitude': 31.200777971839187, 'longitude': 121.44591839540435 },
    { 'latitude': 31.201206263325624, 'longitude': 121.4470261395063 },
    { 'latitude': 31.201494473891746, 'longitude': 121.44811385650564 },
    { 'latitude': 31.201494366284344, 'longitude': 121.4481737278452 },
    { 'latitude': 31.20162363601294, 'longitude': 121.44861279050637 },
    { 'latitude': 31.20192270598141, 'longitude': 121.44920153048758 },
    { 'latitude': 31.202112153722307, 'longitude': 121.44955077650594 },
    { 'latitude': 31.202670746554848, 'longitude': 121.45044881822135 },
    { 'latitude': 31.202840224623486, 'longitude': 121.4507681105675 },
    { 'latitude': 31.20298965096131, 'longitude': 121.45110735097484 },
    { 'latitude': 31.203396552799873, 'longitude': 121.45280344614218 },
    { 'latitude': 31.203575590203208, 'longitude': 121.45333220716054 },
    { 'latitude': 31.20502637238559, 'longitude': 121.45810047501823 },
    { 'latitude': 31.205434042021757, 'longitude': 121.45925748954312 },
    { 'latitude': 31.205792044503742, 'longitude': 121.46023492644967 },
    { 'latitude': 31.20651837204369, 'longitude': 121.46201018118823 },
    { 'latitude': 31.206756923334176, 'longitude': 121.46268833284704 },
    { 'latitude': 31.207274119035507, 'longitude': 121.46399472801197 },
    { 'latitude': 31.20766205832071, 'longitude': 121.46494207528292 },
    { 'latitude': 31.208319085314184, 'longitude': 121.46630820085988 },
    { 'latitude': 31.20849834661396, 'longitude': 121.46664723042196 },
    { 'latitude': 31.21032040635644, 'longitude': 121.46615880701657 },
    { 'latitude': 31.210991040555957, 'longitude': 121.46602924002941 },
    { 'latitude': 31.2117518854004, 'longitude': 121.46582988169436 },
    { 'latitude': 31.2117518854004, 'longitude': 121.46582988169436 },
    { 'latitude': 31.213894414965317, 'longitude': 121.46520187178493 },
    { 'latitude': 31.21488533821303, 'longitude': 121.46501249892961 },
    { 'latitude': 31.21882970886818, 'longitude': 121.46395583726411 },
    { 'latitude': 31.220161225264242, 'longitude': 121.4635770169358 },
    { 'latitude': 31.22127221314525, 'longitude': 121.46337767108226 },
    { 'latitude': 31.22146241876409, 'longitude': 121.46332782683277 },
    { 'latitude': 31.22268336219237, 'longitude': 121.46316837746465 },
    { 'latitude': 31.222843390427737, 'longitude': 121.46318833567511 },
    { 'latitude': 31.222843367158045, 'longitude': 121.46319830786575 },
    { 'latitude': 31.222843367158045, 'longitude': 121.46319830786575 },
    { 'latitude': 31.222843390427737, 'longitude': 121.46318833567511 },
    { 'latitude': 31.222913376587876, 'longitude': 121.46320828609795 },
    { 'latitude': 31.224143787506673, 'longitude': 121.4632781975263 },
    { 'latitude': 31.224714122881863, 'longitude': 121.4632483302623 },
    { 'latitude': 31.22518448124835, 'longitude': 121.4631885377711 },
    { 'latitude': 31.226275173727974, 'longitude': 121.46310885426382 },
    { 'latitude': 31.226875800334444, 'longitude': 121.46295932234807 },
    { 'latitude': 31.227706925457436, 'longitude': 121.4626402792434 },
    { 'latitude': 31.228838346179124, 'longitude': 121.46225145048241 }]
  static dummyLocusPointsWuHan: mapCommon.LatLng[] =
    [{ 'latitude': 30.55446543006316, 'longitude': 114.50535414078917 },
      { 'latitude': 30.554622743246032, 'longitude': 114.50497062350281 },
      { 'latitude': 30.555146449544978, 'longitude': 114.50420151519222 },
      { 'latitude': 30.555417701359442, 'longitude': 114.50405041735033 },
      { 'latitude': 30.557001234895676, 'longitude': 114.50455631390652 },
      { 'latitude': 30.557953278758934, 'longitude': 114.5047200676718 },
      { 'latitude': 30.558028973976786, 'longitude': 114.50482995308323 },
      { 'latitude': 30.55764912967691, 'longitude': 114.5061249599082 },
      { 'latitude': 30.556920455303846, 'longitude': 114.50782030962125 },
      { 'latitude': 30.55634842386656, 'longitude': 114.50885809458103 },
      { 'latitude': 30.554756646254575, 'longitude': 114.5110562769805 },
      { 'latitude': 30.554575375199867, 'longitude': 114.51102537916381 },
      { 'latitude': 30.55233438933314, 'longitude': 114.50770416307091 },
      { 'latitude': 30.55497748834956, 'longitude': 114.50390384146597 },
      { 'latitude': 30.555441365712614, 'longitude': 114.5031039462691 },
      { 'latitude': 30.556299632801135, 'longitude': 114.5012583893614 },
      { 'latitude': 30.55673521147347, 'longitude': 114.49982132608326 },
      { 'latitude': 30.556836474640654, 'longitude': 114.49967917834083 },
      { 'latitude': 30.557154124330545, 'longitude': 114.49956703430831 },
      { 'latitude': 30.558266208794173, 'longitude': 114.4995373429403 },
      { 'latitude': 30.55843127774418, 'longitude': 114.49963378829172 },
      { 'latitude': 30.558479369721926, 'longitude': 114.50186814042952 },
      { 'latitude': 30.5582461142039, 'longitude': 114.50391457930684 },
      { 'latitude': 30.557644722530924, 'longitude': 114.50609367932171 },
      { 'latitude': 30.556907106458247, 'longitude': 114.50780177934695 },
      { 'latitude': 30.556744333057704, 'longitude': 114.50787329200867 },
      { 'latitude': 30.55590494215303, 'longitude': 114.50714191819603 },
      { 'latitude': 30.55433271393855, 'longitude': 114.50557588006492 },
      { 'latitude': 30.55442160156265, 'longitude': 114.50539159357686 }]
  static dummyLocusPointsNanJin: mapCommon.LatLng[] =
    [{ 'latitude': 32.060151, 'longitude': 118.818259 }, { 'latitude': 32.060151, 'longitude': 118.818269 },
      { 'latitude': 32.060161, 'longitude': 118.818289 }, { 'latitude': 32.060171, 'longitude': 118.818309 },
      { 'latitude': 32.060191, 'longitude': 118.818319 }, { 'latitude': 32.060211, 'longitude': 118.818339 },
      { 'latitude': 32.060241, 'longitude': 118.818369 }, { 'latitude': 32.060261, 'longitude': 118.818379 },
      { 'latitude': 32.060292, 'longitude': 118.818399 }, { 'latitude': 32.060332, 'longitude': 118.818419 },
      { 'latitude': 32.060412, 'longitude': 118.818449 }, { 'latitude': 32.060872, 'longitude': 118.81864 },
      { 'latitude': 32.061353, 'longitude': 118.81883 }, { 'latitude': 32.061403, 'longitude': 118.81885 },
      { 'latitude': 32.061753, 'longitude': 118.81899 }, { 'latitude': 32.061863, 'longitude': 118.81904 },
      { 'latitude': 32.061903, 'longitude': 118.81906 }, { 'latitude': 32.061923, 'longitude': 118.81906 },
      { 'latitude': 32.061963, 'longitude': 118.81907 }, { 'latitude': 32.061983, 'longitude': 118.81907 },
      { 'latitude': 32.062003, 'longitude': 118.81907 }, { 'latitude': 32.062023, 'longitude': 118.81907 },
      { 'latitude': 32.062033, 'longitude': 118.81907 }, { 'latitude': 32.062053, 'longitude': 118.81906 },
      { 'latitude': 32.062073, 'longitude': 118.81905 }, { 'latitude': 32.062083, 'longitude': 118.81904 },
      { 'latitude': 32.062093, 'longitude': 118.81902 }, { 'latitude': 32.062113, 'longitude': 118.819 },
      { 'latitude': 32.062173, 'longitude': 118.81891 }, { 'latitude': 32.062233, 'longitude': 118.81882 },
      { 'latitude': 32.062283, 'longitude': 118.81877 }, { 'latitude': 32.062343, 'longitude': 118.81871 },
      { 'latitude': 32.062452, 'longitude': 118.818639 }, { 'latitude': 32.062522, 'longitude': 118.818589 },
      { 'latitude': 32.062572, 'longitude': 118.818579 }, { 'latitude': 32.062612, 'longitude': 118.818569 },
      { 'latitude': 32.062642, 'longitude': 118.818559 }, { 'latitude': 32.062682, 'longitude': 118.818559 },
      { 'latitude': 32.062732, 'longitude': 118.818569 }, { 'latitude': 32.062802, 'longitude': 118.818589 },
      { 'latitude': 32.063073, 'longitude': 118.81873 }, { 'latitude': 32.063193, 'longitude': 118.8188 },
      { 'latitude': 32.063263, 'longitude': 118.81885 }, { 'latitude': 32.063413, 'longitude': 118.81896 },
      { 'latitude': 32.063493, 'longitude': 118.81903 }, { 'latitude': 32.063564, 'longitude': 118.81908 },
      { 'latitude': 32.063614, 'longitude': 118.81911 }, { 'latitude': 32.063644, 'longitude': 118.81912 },
      { 'latitude': 32.063664, 'longitude': 118.81913 }, { 'latitude': 32.063694, 'longitude': 118.81913 },
      { 'latitude': 32.063714, 'longitude': 118.81913 }, { 'latitude': 32.063774, 'longitude': 118.81913 },
      { 'latitude': 32.063844, 'longitude': 118.81913 }, { 'latitude': 32.063874, 'longitude': 118.81912 },
      { 'latitude': 32.063904, 'longitude': 118.81913 }, { 'latitude': 32.063934, 'longitude': 118.81913 },
      { 'latitude': 32.063954, 'longitude': 118.81914 }, { 'latitude': 32.063984, 'longitude': 118.81915 },
      { 'latitude': 32.064044, 'longitude': 118.81917 }, { 'latitude': 32.064113999999996, 'longitude': 118.81922 },
      { 'latitude': 32.064164, 'longitude': 118.819251 }, { 'latitude': 32.064194, 'longitude': 118.819281 },
      { 'latitude': 32.064214, 'longitude': 118.819301 }, { 'latitude': 32.064244, 'longitude': 118.819341 },
      { 'latitude': 32.064264, 'longitude': 118.819371 }, { 'latitude': 32.064284, 'longitude': 118.819421 },
      { 'latitude': 32.064314, 'longitude': 118.819491 }, { 'latitude': 32.064345, 'longitude': 118.819551 },
      { 'latitude': 32.064375, 'longitude': 118.819591 }, { 'latitude': 32.064385, 'longitude': 118.819611 },
      { 'latitude': 32.064405, 'longitude': 118.819621 }, { 'latitude': 32.064415, 'longitude': 118.819631 },
      { 'latitude': 32.064435, 'longitude': 118.819631 }, { 'latitude': 32.064455, 'longitude': 118.819631 },
      { 'latitude': 32.064475, 'longitude': 118.819631 }, { 'latitude': 32.064495, 'longitude': 118.819631 },
      { 'latitude': 32.064525, 'longitude': 118.819631 }, { 'latitude': 32.064565, 'longitude': 118.819611 },
      { 'latitude': 32.064625, 'longitude': 118.819581 }, { 'latitude': 32.064735, 'longitude': 118.819511 },
      { 'latitude': 32.064804, 'longitude': 118.819451 }, { 'latitude': 32.064864, 'longitude': 118.819401 },
      { 'latitude': 32.064904, 'longitude': 118.819351 }, { 'latitude': 32.064934, 'longitude': 118.819311 },
      { 'latitude': 32.064954, 'longitude': 118.819281 }, { 'latitude': 32.064974, 'longitude': 118.81924 },
      { 'latitude': 32.065004, 'longitude': 118.81914 }, { 'latitude': 32.065024, 'longitude': 118.8191 },
      { 'latitude': 32.065034, 'longitude': 118.81907 }, { 'latitude': 32.065044, 'longitude': 118.81905 },
      { 'latitude': 32.065054, 'longitude': 118.81904 }, { 'latitude': 32.065074, 'longitude': 118.81903 },
      { 'latitude': 32.065084, 'longitude': 118.81902 }, { 'latitude': 32.065104, 'longitude': 118.81902 },
      { 'latitude': 32.065124, 'longitude': 118.81902 }, { 'latitude': 32.065144, 'longitude': 118.81902 },
      { 'latitude': 32.065164, 'longitude': 118.81902 }, { 'latitude': 32.065174, 'longitude': 118.81904 },
      { 'latitude': 32.065194, 'longitude': 118.81906 }, { 'latitude': 32.065204, 'longitude': 118.81908 },
      { 'latitude': 32.065214, 'longitude': 118.81912 }, { 'latitude': 32.065224, 'longitude': 118.81918 },
      { 'latitude': 32.065234, 'longitude': 118.819311 }, { 'latitude': 32.065255, 'longitude': 118.819421 },
      { 'latitude': 32.065285, 'longitude': 118.819531 }, { 'latitude': 32.065295, 'longitude': 118.819581 },
      { 'latitude': 32.065305, 'longitude': 118.819611 }, { 'latitude': 32.065325, 'longitude': 118.819641 },
      { 'latitude': 32.065345, 'longitude': 118.819671 }, { 'latitude': 32.065375, 'longitude': 118.819691 },
      { 'latitude': 32.065475, 'longitude': 118.819741 }, { 'latitude': 32.065605, 'longitude': 118.819802 },
      { 'latitude': 32.065746, 'longitude': 118.819892 }, { 'latitude': 32.065886, 'longitude': 118.819982 },
      { 'latitude': 32.065946, 'longitude': 118.820022 }, { 'latitude': 32.065996, 'longitude': 118.820052 },
      { 'latitude': 32.066036, 'longitude': 118.820062 }, { 'latitude': 32.066086, 'longitude': 118.820072 },
      { 'latitude': 32.066136, 'longitude': 118.820082 }, { 'latitude': 32.066226, 'longitude': 118.820092 },
      { 'latitude': 32.066336, 'longitude': 118.820122 }, { 'latitude': 32.066406, 'longitude': 118.820142 },
      { 'latitude': 32.066666, 'longitude': 118.820252 }, { 'latitude': 32.066797, 'longitude': 118.820303 },
      { 'latitude': 32.066847, 'longitude': 118.820313 }, { 'latitude': 32.066907, 'longitude': 118.820323 },
      { 'latitude': 32.066947, 'longitude': 118.820323 }, { 'latitude': 32.066997, 'longitude': 118.820343 },
      { 'latitude': 32.067027, 'longitude': 118.820353 }, { 'latitude': 32.067067, 'longitude': 118.820373 },
      { 'latitude': 32.067117, 'longitude': 118.820423 }, { 'latitude': 32.067157, 'longitude': 118.820473 },
      { 'latitude': 32.067257, 'longitude': 118.820613 }, { 'latitude': 32.067348, 'longitude': 118.820753 },
      { 'latitude': 32.067398, 'longitude': 118.820874 }, { 'latitude': 32.067468, 'longitude': 118.821014 },
      { 'latitude': 32.067488, 'longitude': 118.821074 }, { 'latitude': 32.067498, 'longitude': 118.821124 },
      { 'latitude': 32.067508, 'longitude': 118.821164 }, { 'latitude': 32.067508, 'longitude': 118.821214 },
      { 'latitude': 32.067509, 'longitude': 118.821275 }, { 'latitude': 32.067499, 'longitude': 118.821345 },
      { 'latitude': 32.067489, 'longitude': 118.821415 }, { 'latitude': 32.067449, 'longitude': 118.821715 },
      { 'latitude': 32.067439, 'longitude': 118.821776 }, { 'latitude': 32.06744, 'longitude': 118.821826 },
      { 'latitude': 32.06744, 'longitude': 118.821866 }, { 'latitude': 32.06745, 'longitude': 118.821916 },
      { 'latitude': 32.06746, 'longitude': 118.821956 }, { 'latitude': 32.06748, 'longitude': 118.821996 },
      { 'latitude': 32.0675, 'longitude': 118.822026 }, { 'latitude': 32.06752, 'longitude': 118.822066 },
      { 'latitude': 32.06756, 'longitude': 118.822106 }, { 'latitude': 32.06759, 'longitude': 118.822146 },
      { 'latitude': 32.06762, 'longitude': 118.822166 }, { 'latitude': 32.06765, 'longitude': 118.822186 },
      { 'latitude': 32.06769, 'longitude': 118.822196 }, { 'latitude': 32.06772, 'longitude': 118.822207 },
      { 'latitude': 32.06774, 'longitude': 118.822207 }, { 'latitude': 32.06779, 'longitude': 118.822206 },
      { 'latitude': 32.06794, 'longitude': 118.822206 }, { 'latitude': 32.06797, 'longitude': 118.822206 },
      { 'latitude': 32.06802, 'longitude': 118.822186 }, { 'latitude': 32.06806, 'longitude': 118.822176 },
      { 'latitude': 32.06811, 'longitude': 118.822146 }, { 'latitude': 32.06814, 'longitude': 118.822136 },
      { 'latitude': 32.06817, 'longitude': 118.822126 }, { 'latitude': 32.0682, 'longitude': 118.822126 },
      { 'latitude': 32.06822, 'longitude': 118.822126 }, { 'latitude': 32.06824, 'longitude': 118.822126 },
      { 'latitude': 32.06827, 'longitude': 118.822136 }, { 'latitude': 32.06832, 'longitude': 118.822166 },
      { 'latitude': 32.06838, 'longitude': 118.822196 }, { 'latitude': 32.0684, 'longitude': 118.822216 },
      { 'latitude': 32.068431, 'longitude': 118.822226 }, { 'latitude': 32.068461, 'longitude': 118.822226 },
      { 'latitude': 32.068491, 'longitude': 118.822226 }, { 'latitude': 32.068511, 'longitude': 118.822226 },
      { 'latitude': 32.068541, 'longitude': 118.822226 }, { 'latitude': 32.068581, 'longitude': 118.822216 },
      { 'latitude': 32.068621, 'longitude': 118.822206 }, { 'latitude': 32.06865, 'longitude': 118.822186 },
      { 'latitude': 32.06869, 'longitude': 118.822166 }, { 'latitude': 32.06873, 'longitude': 118.822136 },
      { 'latitude': 32.06878, 'longitude': 118.822096 }, { 'latitude': 32.06885, 'longitude': 118.822016 },
      { 'latitude': 32.06888, 'longitude': 118.821986 }, { 'latitude': 32.06891, 'longitude': 118.821966 },
      { 'latitude': 32.06894, 'longitude': 118.821946 }, { 'latitude': 32.06897, 'longitude': 118.821936 },
      { 'latitude': 32.069, 'longitude': 118.821926 }, { 'latitude': 32.06902, 'longitude': 118.821916 },
      { 'latitude': 32.06904, 'longitude': 118.821916 }, { 'latitude': 32.06906, 'longitude': 118.821926 },
      { 'latitude': 32.06907, 'longitude': 118.821926 }, { 'latitude': 32.06909, 'longitude': 118.821936 },
      { 'latitude': 32.0691, 'longitude': 118.821946 }, { 'latitude': 32.06911, 'longitude': 118.821956 },
      { 'latitude': 32.06912, 'longitude': 118.821966 }, { 'latitude': 32.06913, 'longitude': 118.821986 },
      { 'latitude': 32.06914, 'longitude': 118.822006 }, { 'latitude': 32.06914, 'longitude': 118.822026 },
      { 'latitude': 32.06914, 'longitude': 118.822046 }, { 'latitude': 32.06914, 'longitude': 118.822056 },
      { 'latitude': 32.06913, 'longitude': 118.822086 }, { 'latitude': 32.06913, 'longitude': 118.822106 },
      { 'latitude': 32.06911, 'longitude': 118.822126 }, { 'latitude': 32.06909, 'longitude': 118.822146 },
      { 'latitude': 32.069071, 'longitude': 118.822166 }, { 'latitude': 32.069041, 'longitude': 118.822176 },
      { 'latitude': 32.068991, 'longitude': 118.822196 }, { 'latitude': 32.068921, 'longitude': 118.822226 },
      { 'latitude': 32.068841, 'longitude': 118.822257 }, { 'latitude': 32.068661, 'longitude': 118.822347 },
      { 'latitude': 32.068571, 'longitude': 118.822397 }, { 'latitude': 32.068461, 'longitude': 118.822447 },
      { 'latitude': 32.068401, 'longitude': 118.822467 }, { 'latitude': 32.068301, 'longitude': 118.822507 },
      { 'latitude': 32.068181, 'longitude': 118.822547 }, { 'latitude': 32.068121, 'longitude': 118.822577 },
      { 'latitude': 32.068091, 'longitude': 118.822577 }, { 'latitude': 32.068071, 'longitude': 118.822587 },
      { 'latitude': 32.068041, 'longitude': 118.822597 }, { 'latitude': 32.067941, 'longitude': 118.822597 },
      { 'latitude': 32.067891, 'longitude': 118.822607 }, { 'latitude': 32.067861, 'longitude': 118.822607 },
      { 'latitude': 32.067841, 'longitude': 118.822617 }, { 'latitude': 32.067821, 'longitude': 118.822627 },
      { 'latitude': 32.067791, 'longitude': 118.822637 }, { 'latitude': 32.067761, 'longitude': 118.822647 },
      { 'latitude': 32.067611, 'longitude': 118.822738 }, { 'latitude': 32.067561, 'longitude': 118.822768 },
      { 'latitude': 32.067531, 'longitude': 118.822788 }, { 'latitude': 32.067501, 'longitude': 118.822798 },
      { 'latitude': 32.067471, 'longitude': 118.822808 }, { 'latitude': 32.067441, 'longitude': 118.822818 },
      { 'latitude': 32.067411, 'longitude': 118.822808 }, { 'latitude': 32.067381, 'longitude': 118.822798 },
      { 'latitude': 32.067351, 'longitude': 118.822778 }, { 'latitude': 32.067321, 'longitude': 118.822748 },
      { 'latitude': 32.067151, 'longitude': 118.822567 }, { 'latitude': 32.067041, 'longitude': 118.822447 },
      { 'latitude': 32.06694, 'longitude': 118.822357 }, { 'latitude': 32.06685, 'longitude': 118.822287 },
      { 'latitude': 32.0668, 'longitude': 118.822247 }, { 'latitude': 32.06673, 'longitude': 118.822187 },
      { 'latitude': 32.06669, 'longitude': 118.822167 }, { 'latitude': 32.06663, 'longitude': 118.822146 },
      { 'latitude': 32.06659, 'longitude': 118.822126 }, { 'latitude': 32.06654, 'longitude': 118.822116 },
      { 'latitude': 32.06649, 'longitude': 118.822106 }, { 'latitude': 32.06639, 'longitude': 118.822096 },
      { 'latitude': 32.0659, 'longitude': 118.822066 }, { 'latitude': 32.06571, 'longitude': 118.822056 },
      { 'latitude': 32.06564, 'longitude': 118.822056 }, { 'latitude': 32.0656, 'longitude': 118.822046 },
      { 'latitude': 32.06555, 'longitude': 118.822036 }, { 'latitude': 32.065499, 'longitude': 118.822016 },
      { 'latitude': 32.065329, 'longitude': 118.821966 }, { 'latitude': 32.065289, 'longitude': 118.821946 },
      { 'latitude': 32.065239, 'longitude': 118.821936 }, { 'latitude': 32.065219, 'longitude': 118.821936 },
      { 'latitude': 32.065199, 'longitude': 118.821936 }, { 'latitude': 32.065179, 'longitude': 118.821936 },
      { 'latitude': 32.065159, 'longitude': 118.821936 }, { 'latitude': 32.065139, 'longitude': 118.821936 },
      { 'latitude': 32.065119, 'longitude': 118.821946 }, { 'latitude': 32.065109, 'longitude': 118.821956 },
      { 'latitude': 32.065099, 'longitude': 118.821966 }, { 'latitude': 32.065089, 'longitude': 118.821966 },
      { 'latitude': 32.065089, 'longitude': 118.821966 }, { 'latitude': 32.065089, 'longitude': 118.821976 },
      { 'latitude': 32.065079, 'longitude': 118.821986 }, { 'latitude': 32.065079, 'longitude': 118.821996 },
      { 'latitude': 32.065069, 'longitude': 118.822016 }, { 'latitude': 32.065069, 'longitude': 118.822036 },
      { 'latitude': 32.065059, 'longitude': 118.822066 }, { 'latitude': 32.06506, 'longitude': 118.822086 },
      { 'latitude': 32.06507, 'longitude': 118.822107 }, { 'latitude': 32.06507, 'longitude': 118.822127 },
      { 'latitude': 32.06508, 'longitude': 118.822137 }, { 'latitude': 32.06509, 'longitude': 118.822157 },
      { 'latitude': 32.0651, 'longitude': 118.822167 }, { 'latitude': 32.06511, 'longitude': 118.822177 },
      { 'latitude': 32.06511, 'longitude': 118.822187 }, { 'latitude': 32.06513, 'longitude': 118.822197 },
      { 'latitude': 32.06515, 'longitude': 118.822207 }, { 'latitude': 32.06516, 'longitude': 118.822207 },
      { 'latitude': 32.06517, 'longitude': 118.822207 }, { 'latitude': 32.06518, 'longitude': 118.822207 },
      { 'latitude': 32.0652, 'longitude': 118.822197 }, { 'latitude': 32.06521, 'longitude': 118.822197 },
      { 'latitude': 32.06529, 'longitude': 118.822157 }, { 'latitude': 32.06533, 'longitude': 118.822137 },
      { 'latitude': 32.06535, 'longitude': 118.822127 }, { 'latitude': 32.06537, 'longitude': 118.822127 },
      { 'latitude': 32.06538, 'longitude': 118.822117 }, { 'latitude': 32.06539, 'longitude': 118.822117 },
      { 'latitude': 32.06541, 'longitude': 118.822117 }, { 'latitude': 32.06542, 'longitude': 118.822117 },
      { 'latitude': 32.06544, 'longitude': 118.822117 }, { 'latitude': 32.06546, 'longitude': 118.822127 },
      { 'latitude': 32.06548, 'longitude': 118.822137 }, { 'latitude': 32.0656, 'longitude': 118.822197 },
      { 'latitude': 32.06574, 'longitude': 118.822287 }, { 'latitude': 32.06604, 'longitude': 118.822487 },
      { 'latitude': 32.066371, 'longitude': 118.822708 }, { 'latitude': 32.066561, 'longitude': 118.822848 },
      { 'latitude': 32.066691, 'longitude': 118.822958 }, { 'latitude': 32.066772, 'longitude': 118.823038 },
      { 'latitude': 32.066802, 'longitude': 118.823078 }, { 'latitude': 32.066832, 'longitude': 118.823119 },
      { 'latitude': 32.066862, 'longitude': 118.823179 }, { 'latitude': 32.066882, 'longitude': 118.823229 },
      { 'latitude': 32.066912, 'longitude': 118.823309 }, { 'latitude': 32.066993, 'longitude': 118.823499 },
      { 'latitude': 32.067013, 'longitude': 118.823549 }, { 'latitude': 32.067043, 'longitude': 118.8236 },
      { 'latitude': 32.067083, 'longitude': 118.82366 }, { 'latitude': 32.067133, 'longitude': 118.82371 },
      { 'latitude': 32.067203, 'longitude': 118.82376 }, { 'latitude': 32.067273, 'longitude': 118.82379 },
      { 'latitude': 32.067373, 'longitude': 118.82381 }, { 'latitude': 32.067443, 'longitude': 118.82384 },
      { 'latitude': 32.067533, 'longitude': 118.82386 }, { 'latitude': 32.067693, 'longitude': 118.8239 },
      { 'latitude': 32.067744, 'longitude': 118.82393 }]
  // 计算公式说明：
  // 计时运动/健走：步频110步/分钟，步幅70cm，速度4.62公里/小时，消耗=4.0×65×时间(小时)
  // 跑步：步频150步/分钟，步幅90cm，速度8.10公里/小时，消耗=9.0×65×时间(小时)
  // 骑行：速度20km/h，距离=20×时间(小时)×1000米，消耗=130瓦×时间(小时)×3.6，无步数
  static records: SportRecord[] = [
  // 2025年11月2日 - 包含各种运动类型和时长（总计60分钟）
    {
      year: 2025,
      month: 11,
      day: 2,
      totalTarget: {
        stepCount: 10000,
        distance: 20000,
        deplete: 500,
        timeLength: 1800
      },
      totalStepCount: 7000, // 计时运动10分钟(1100) + 计时运动15分钟(1650) + 健走10分钟(1100) + 健走15分钟(1650) + 跑步10分钟(1500)
      totalDistance: 5200, // 计时运动10分钟(770) + 计时运动15分钟(1155) + 健走10分钟(770) + 健走15分钟(1155) + 跑步10分钟(1350)
      totalDeplete: 314, // 计时运动10分钟(43) + 计时运动15分钟(65) + 健走10分钟(43) + 健走15分钟(65) + 跑步10分钟(98)
      totalSportTimeLength: 3600, // 10+15+10+15+10 = 60分钟 = 3600秒
      // 根据sportItemList的小时和分钟精确分配：9:00计时10分钟(9点)、9:10计时15分钟(9点)、10:00健走10分钟(10点)、10:10健走15分钟(10点)、11:00跑步10分钟(11点)
      // 验证：hourStepCount总和=1100+1650+1100+1650+1500=7000 ✓, hourDistance总和=770+1155+770+1155+1350=5200 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 2750, 2750, 1500, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1925, 1925, 1350, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 108, 108, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1500, 1500, 600, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
      // 计时运动 10分钟：步数1100，距离770米，消耗43大卡
        {
          type: SportType.CLOCK_BASE_EXCERCISE,
          childType: ChildSportType.TIMING_SPORT,
          hour: 9,
          minute: 0,
          distance: 770,
          timeLength: 600,
          deplete: 43,
          target: {
            targetType: TargetType.TIME_LENGTH,
            value: 600
          },
          stepCount: 1100
        },
        // 计时运动 15分钟：步数1650，距离1155米，消耗65大卡
        {
          type: SportType.CLOCK_BASE_EXCERCISE,
          childType: ChildSportType.TIMING_SPORT,
          hour: 9,
          minute: 10,
          distance: 1155,
          timeLength: 900,
          deplete: 65,
          target: {
            targetType: TargetType.TIME_LENGTH,
            value: 900
          },
          stepCount: 1650
        },
        // 健走 10分钟：步数1100，距离770米，消耗43大卡
        {
          type: SportType.WALKING,
          childType: ChildSportType.FREE_WALKING,
          hour: 10,
          minute: 0,
          distance: 770,
          timeLength: 600,
          deplete: 43,
          stepCount: 1100,
          locusPoints: MockSportRecord.dummyLocusPoints
        },
        // 健走 15分钟：步数1650，距离1155米，消耗65大卡
        {
          type: SportType.WALKING,
          childType: ChildSportType.TARGET_WALKING,
          hour: 10,
          minute: 10,
          distance: 1155,
          timeLength: 900,
          deplete: 65,
          target: {
            targetType: TargetType.DISTANCE,
            value: 1200
          },
          stepCount: 1650,
          locusPoints: MockSportRecord.dummyLocusPointsNanJin
        },
        // 跑步 10分钟：步数1500，距离1350米，消耗98大卡
        {
          type: SportType.JOGGING,
          childType: ChildSportType.TARGET_JOGGING,
          hour: 11,
          minute: 0,
          distance: 3300,
          timeLength: 600,
          deplete: 98,
          target: {
            targetType: TargetType.DISTANCE,
            value: 1500
          },
          stepCount: 1500,
          locusPoints: MockSportRecord.dummyLocusPoints1
        }
      ]
    },
    // 2025年9月30日 - 计时运动30分钟（总计30分钟）
    {
      year: 2025,
      month: 9,
      day: 30,
      totalTarget: {
        stepCount: 12000,
        distance: 10000,
        deplete: 500,
        timeLength: 1800
      },
      totalStepCount: 3300, // 计时运动30分钟(3300)
      totalDistance: 2310, // 计时运动30分钟(2310)
      totalDeplete: 130, // 计时运动30分钟(130)
      totalSportTimeLength: 1800, // 30分钟 = 1800秒
      // 根据sportItemList的hour和minute精确分配：9:00计时30分钟(9点)
      // 验证：hourStepCount总和=3300 ✓, hourDistance总和=2310 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 3300, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 2310, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 130, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1800, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
      // 计时运动 30分钟：步数3300，距离2310米，消耗130大卡
        {
          type: SportType.CLOCK_BASE_EXCERCISE,
          childType: ChildSportType.TIMING_SPORT,
          hour: 9,
          minute: 0,
          distance: 2310,
          timeLength: 1800,
          deplete: 130,
          target: {
            targetType: TargetType.TIME_LENGTH,
            value: 1800
          },
          stepCount: 3300
        }
      ]
    },
    // 2025年9月28日 - 跑步20分钟 + 跑步15分钟 + 骑行10分钟（总计45分钟）
    {
      year: 2025,
      month: 9,
      day: 28,
      totalTarget: {
        stepCount: 10000,
        distance: 30000,
        deplete: 700,
        timeLength: 1800
      },
      totalStepCount: 5250, // 跑步20分钟(3000) + 跑步15分钟(2250)
      totalDistance: 8058, // 跑步20分钟(2700) + 跑步15分钟(2025) + 骑行10分钟(3333)
      totalDeplete: 419, // 跑步20分钟(195) + 跑步15分钟(146) + 骑行10分钟(78)
      totalSportTimeLength: 2700, // 20+15+10 = 45分钟 = 2700秒
      // 根据sportItemList的hour和minute精确分配：8:00跑步20分钟(8点)、15:00跑步15分钟(15点)、17:00骑行10分钟(17点)
      // 验证：hourStepCount总和=3000+2250=5250 ✓, hourDistance总和=2700+2025+3333=8058 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 3000, 0, 0, 0, 0, 0, 0, 2250, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 2700, 0, 0, 0, 0, 0, 0, 2025, 0, 3333, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 195, 0, 0, 0, 0, 0, 0, 146, 0, 78, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 1200, 0, 0, 0, 0, 0, 0, 900, 0, 600, 0, 0, 0, 0, 0, 0],
      sportItemList: [
      // 跑步 20分钟：步数3000，距离2700米，消耗195大卡（9.0×65×20/60=195）
        {
          type: SportType.JOGGING,
          childType: ChildSportType.TARGET_JOGGING,
          hour: 8,
          minute: 0,
          distance: 2700,
          timeLength: 1200,
          deplete: 195,
          target: {
            targetType: TargetType.DISTANCE,
            value: 3000
          },
          stepCount: 3000,
          locusPoints: MockSportRecord.dummyLocusPointsNanJin
        },
        // 跑步 15分钟：步数2250，距离2025米，消耗146大卡（9.0×65×15/60=146.25≈146）
        {
          type: SportType.JOGGING,
          childType: ChildSportType.TARGET_JOGGING,
          hour: 15,
          minute: 0,
          distance: 2025,
          timeLength: 900,
          deplete: 146,
          target: {
            targetType: TargetType.DISTANCE,
            value: 2000
          },
          stepCount: 2250,
          locusPoints: MockSportRecord.dummyLocusPoints1
        },
        // 骑行 10分钟：距离3333米，消耗78大卡（130瓦*10/60小时*3.6=78，速度20km/h*10/60h=3.333km=3333米）
        {
          type: SportType.CYCLING,
          childType: ChildSportType.TARGET_CYCLING,
          hour: 17,
          minute: 0,
          distance: 3300,
          timeLength: 600,
          deplete: 78,
          target: {
            targetType: TargetType.DISTANCE,
            value: 3300
          },
          stepCount: 0,
          locusPoints: MockSportRecord.dummyLocusPointsWuHan
        }
      ]
    },
    // 2025年9月25日 - 健走12分钟（用户示例）+ 计时运动30分钟
    {
      year: 2025,
      month: 9,
      day: 25,
      totalTarget: {
        stepCount: 5000,
        distance: 5000,
        deplete: 200,
        timeLength: 1800
      },
      totalStepCount: 4620, // 健走12分钟(1320) + 计时运动30分钟(3300)
      totalDistance: 3234, // 健走12分钟(924) + 计时运动30分钟(2310)
      totalDeplete: 182, // 健走12分钟(52) + 计时运动30分钟(130)
      totalSportTimeLength: 2520, // 12+30 = 42分钟 = 2520秒
      // 根据sportItemList的hour和minute精确分配：9:00计时30分钟(9点)、10:00健走12分钟(10点)
      // 验证：hourStepCount总和=3300+1320=4620 ✓, hourDistance总和=2310+924=3234 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 3300, 1320, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 2310, 924, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 130, 52, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1800, 720, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
      // 健走 12分钟：步数1320，距离924米，消耗52大卡（用户示例）
        {
          type: SportType.WALKING,
          childType: ChildSportType.FREE_WALKING,
          hour: 10,
          minute: 0,
          distance: 3300,
          timeLength: 720,
          deplete: 52,
          stepCount: 1320,
          locusPoints: MockSportRecord.dummyLocusPoints1
        },
        // 计时运动 30分钟：步数3300，距离2310米，消耗130大卡
        {
          type: SportType.CLOCK_BASE_EXCERCISE,
          childType: ChildSportType.TIMING_SPORT,
          hour: 9,
          minute: 0,
          distance: 2310,
          timeLength: 1800,
          deplete: 130,
          target: {
            targetType: TargetType.TIME_LENGTH,
            value: 1800
          },
          stepCount: 3300
        }
      ]
    },
    // 2025年9月22日 - 跑步30分钟（总计30分钟）
    {
      year: 2025,
      month: 9,
      day: 22,
      totalTarget: {
        stepCount: 5000,
        distance: 15000,
        deplete: 450,
        timeLength: 1800
      },
      totalStepCount: 4500, // 跑步30分钟(4500)
      totalDistance: 4050, // 跑步30分钟(4050)
      totalDeplete: 293, // 跑步30分钟(293)
      totalSportTimeLength: 1800, // 30分钟 = 1800秒
      // 根据sportItemList的hour和minute精确分配：12:00跑步30分钟(12点)
      // 验证：hourStepCount总和=4500 ✓, hourDistance总和=4050 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4500, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4050, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 293, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1800, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
      // 跑步 30分钟：步数4500，距离4050米，消耗293大卡
        {
          type: SportType.JOGGING,
          childType: ChildSportType.TARGET_JOGGING,
          hour: 12,
          minute: 0,
          distance: 4050,
          timeLength: 1800,
          deplete: 293,
          target: {
            targetType: TargetType.DISTANCE,
            value: 4000
          },
          stepCount: 4500,
          locusPoints: MockSportRecord.dummyLocusPoints1
        }
      ]
    },
    // 2025年9月21日 - 健走30分钟 + 计时运动15分钟
    {
      year: 2025,
      month: 9,
      day: 21,
      totalTarget: {
        stepCount: 5000,
        distance: 4000,
        deplete: 200,
        timeLength: 1800
      },
      totalStepCount: 4950, // 健走30分钟(3300) + 计时运动15分钟(1650)
      totalDistance: 3465, // 健走30分钟(2310) + 计时运动15分钟(1155)
      totalDeplete: 195, // 健走30分钟(130) + 计时运动15分钟(65)
      totalSportTimeLength: 2700, // 30+15 = 45分钟 = 2700秒
      // 根据sportItemList的hour和minute精确分配：9:00计时15分钟(9点)、18:00健走30分钟(18点)
      // 验证：hourStepCount总和=1650+3300=4950 ✓, hourDistance总和=1155+2310=3465 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1650, 0, 0, 0, 0, 0, 0, 0, 0, 3300, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1155, 0, 0, 0, 0, 0, 0, 0, 0, 2310, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 65, 0, 0, 0, 0, 0, 0, 0, 0, 130, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 900, 0, 0, 0, 0, 0, 0, 0, 0, 1800, 0, 0, 0, 0, 0],
      sportItemList: [
      // 计时运动 15分钟：步数1650，距离1155米，消耗65大卡
        {
          type: SportType.CLOCK_BASE_EXCERCISE,
          childType: ChildSportType.TIMING_SPORT,
          hour: 9,
          minute: 0,
          distance: 1155,
          timeLength: 900,
          deplete: 65,
          target: {
            targetType: TargetType.TIME_LENGTH,
            value: 900
          },
          stepCount: 1650
        },
        // 健走 30分钟：步数3300，距离2310米，消耗130大卡
        {
          type: SportType.WALKING,
          childType: ChildSportType.TARGET_WALKING,
          hour: 18,
          minute: 0,
          distance: 2310,
          timeLength: 1800,
          deplete: 130,
          target: {
            targetType: TargetType.DISTANCE,
            value: 2500
          },
          stepCount: 3300,
          locusPoints: MockSportRecord.dummyLocusPoints
        }
      ]
    },
    // 2025年9月20日 - 骑行15分钟 + 骑行60分钟
    {
      year: 2025,
      month: 9,
      day: 20,
      totalTarget: {
        stepCount: 0,
        distance: 25000,
        deplete: 350,
        timeLength: 1800
      },
      totalStepCount: 0, // 骑行无步数
      totalDistance: 15000, // 骑行20分钟(6667) + 骑行25分钟(8333)
      totalDeplete: 351, // 骑行20分钟(156) + 骑行25分钟(195)
      totalSportTimeLength: 2700, // 20+25 = 45分钟 = 2700秒
      // 根据sportItemList的hour和minute精确分配：7:00骑行20分钟(7点)、19:00骑行25分钟(19点)
      // 验证：hourStepCount总和=0 ✓, hourDistance总和=6667+8333=15000 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 6667, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8333, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 156, 0, 0, 0, 0, 0, 0, 0, 0, 0, 195, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1500, 0, 0, 0, 0],
      sportItemList: [
      // 骑行 20分钟：距离6667米，消耗156大卡（130瓦*20/60小时*3.6=156，速度20km/h*20/60h=6.667km=6667米）
        {
          type: SportType.CYCLING,
          childType: ChildSportType.TARGET_CYCLING,
          hour: 7,
          minute: 0,
          distance: 6667,
          timeLength: 1200,
          deplete: 156,
          target: {
            targetType: TargetType.DISTANCE,
            value: 6500
          },
          stepCount: 0,
          locusPoints: MockSportRecord.dummyLocusPointsNanJin
        },
        // 骑行 25分钟：距离8333米，消耗195大卡（130瓦*25/60小时*3.6=195，速度20km/h*25/60h=8.333km=8333米）
        {
          type: SportType.CYCLING,
          childType: ChildSportType.TARGET_CYCLING,
          hour: 19,
          minute: 0,
          distance: 8333,
          timeLength: 1500,
          deplete: 195,
          target: {
            targetType: TargetType.DISTANCE,
            value: 8000
          },
          stepCount: 0
        }
      ]
    },
    // 2025年9月18日 - 健走30分钟（总计30分钟）
    {
      year: 2025,
      month: 9,
      day: 18,
      totalTarget: {
        stepCount: 7000,
        distance: 5000,
        deplete: 300,
        timeLength: 1800
      },
      totalStepCount: 3300, // 健走30分钟(3300)
      totalDistance: 2310, // 健走30分钟(2310)
      totalDeplete: 130, // 健走30分钟(130)
      totalSportTimeLength: 1800, // 30分钟 = 1800秒
      // 根据sportItemList的hour和minute精确分配：18:00健走30分钟(18点)
      // 验证：hourStepCount总和=3300 ✓, hourDistance总和=2310 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3300, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2310, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 130, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1800, 0, 0, 0, 0, 0],
      sportItemList: [
      // 健走 30分钟：步数3300，距离2310米，消耗130大卡
        {
          type: SportType.WALKING,
          childType: ChildSportType.TARGET_WALKING,
          hour: 18,
          minute: 0,
          distance: 2310,
          timeLength: 1800,
          deplete: 130,
          target: {
            targetType: TargetType.DISTANCE,
            value: 2500
          },
          stepCount: 3300,
          locusPoints: MockSportRecord.dummyLocusPoints
        }
      ]
    },
    // 2025年9月1日 - 空记录（无运动）
    {
      year: 2025,
      month: 9,
      day: 1,
      totalTarget: {
        stepCount: 8000,
        distance: 10000,
        deplete: 600,
        timeLength: 1800
      },
      totalStepCount: 0,
      totalDistance: 0,
      totalDeplete: 0,
      totalSportTimeLength: 0,
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: []
    },
    // 2025年8月25日 - 计时运动20分钟 + 跑步20分钟（总计40分钟）
    {
      year: 2025,
      month: 8,
      day: 25,
      totalTarget: {
        stepCount: 7000,
        distance: 6000,
        deplete: 400,
        timeLength: 1800
      },
      totalStepCount: 5200, // 计时运动20分钟(2200) + 跑步20分钟(3000)
      totalDistance: 4240, // 计时运动20分钟(1540) + 跑步20分钟(2700)
      totalDeplete: 282, // 计时运动20分钟(87) + 跑步20分钟(195)
      totalSportTimeLength: 2400, // 20+20 = 40分钟 = 2400秒
      // 根据sportItemList的hour和minute精确分配：9:00计时20分钟(9点)、15:00跑步20分钟(15点)
      // 验证：hourStepCount总和=2200+3000=5200 ✓, hourDistance总和=1540+2700=4240 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 2200, 0, 0, 0, 0, 0, 3000, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1540, 0, 0, 0, 0, 0, 2700, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 87, 0, 0, 0, 0, 0, 195, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1200, 0, 0, 0, 0, 0, 1200, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
      // 计时运动 20分钟：步数2200，距离1540米，消耗87大卡（4.0×65×20/60=87）
        {
          type: SportType.CLOCK_BASE_EXCERCISE,
          childType: ChildSportType.TIMING_SPORT,
          hour: 9,
          minute: 0,
          distance: 1540,
          timeLength: 1200,
          deplete: 87,
          target: {
            targetType: TargetType.TIME_LENGTH,
            value: 1200
          },
          stepCount: 2200
        },
        // 跑步 20分钟：步数3000，距离2700米，消耗195大卡（9.0×65×20/60=195）
        {
          type: SportType.JOGGING,
          childType: ChildSportType.TARGET_JOGGING,
          hour: 15,
          minute: 0,
          distance: 2700,
          timeLength: 1200,
          deplete: 195,
          target: {
            targetType: TargetType.DISTANCE,
            value: 3000
          },
          stepCount: 3000,
          locusPoints: MockSportRecord.dummyLocusPoints1
        }
      ]
    },
    // 2025年8月12日 - 跑步45分钟
    {
      year: 2025,
      month: 8,
      day: 12,
      totalTarget: {
        stepCount: 7000,
        distance: 7000,
        deplete: 500,
        timeLength: 1800
      },
      totalStepCount: 6750, // 跑步45分钟(6750)
      totalDistance: 6075, // 跑步45分钟(6075)
      totalDeplete: 439, // 跑步45分钟(439)
      totalSportTimeLength: 2700, // 45分钟 = 2700秒
      // 根据sportItemList的hour和minute精确分配：8:00跑步45分钟(8点)
      // 验证：hourStepCount总和=6750 ✓, hourDistance总和=6075 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 6750, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 6075, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 439, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 2700, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
      // 跑步 45分钟：步数6750，距离6075米，消耗439大卡
        {
          type: SportType.JOGGING,
          childType: ChildSportType.TARGET_JOGGING,
          hour: 8,
          minute: 0,
          distance: 6075,
          timeLength: 2700,
          deplete: 439,
          target: {
            targetType: TargetType.DISTANCE,
            value: 6000
          },
          stepCount: 6750,
          locusPoints: MockSportRecord.dummyLocusPoints1
        }
      ]
    },
    // 2025年7月2日 - 计时运动25分钟 + 健走10分钟（总计35分钟）
    {
      year: 2025,
      month: 7,
      day: 2,
      totalTarget: {
        stepCount: 7000,
        distance: 5000,
        deplete: 250,
        timeLength: 1800
      },
      totalStepCount: 3850, // 计时运动25分钟(2750) + 健走10分钟(1100)
      totalDistance: 2695, // 计时运动25分钟(1925) + 健走10分钟(770)
      totalDeplete: 139, // 计时运动25分钟(108) + 健走10分钟(43)
      totalSportTimeLength: 2100, // 25+10 = 35分钟 = 2100秒
      // 根据sportItemList的hour和minute精确分配：9:00计时25分钟(9点)、10:00健走10分钟(10点)
      // 验证：hourStepCount总和=2750+1100=3850 ✓, hourDistance总和=1925+770=2695 ✓
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 2750, 1100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1925, 770, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 108, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1500, 600, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
      // 计时运动 25分钟：步数2750，距离1925米，消耗108大卡（4.0×65×25/60=108）
        {
          type: SportType.CLOCK_BASE_EXCERCISE,
          childType: ChildSportType.TIMING_SPORT,
          hour: 9,
          minute: 0,
          distance: 1925,
          timeLength: 1500,
          deplete: 108,
          target: {
            targetType: TargetType.TIME_LENGTH,
            value: 1500
          },
          stepCount: 2750
        },
        // 健走 10分钟：步数1100，距离770米，消耗43大卡
        {
          type: SportType.WALKING,
          childType: ChildSportType.FREE_WALKING,
          hour: 10,
          minute: 0,
          distance: 770,
          timeLength: 600,
          deplete: 43,
          stepCount: 1100,
          locusPoints: MockSportRecord.dummyLocusPoints
        }
      ]
    },
    // 2024年11月14日 - 空记录（无运动）
    {
      year: 2024,
      month: 11,
      day: 14,
      totalTarget: {
        stepCount: 8000,
        distance: 4000,
        deplete: 600,
        timeLength: 1800
      },
      totalStepCount: 0,
      totalDistance: 0,
      totalDeplete: 0,
      totalSportTimeLength: 0,
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: []
    },
    // 2024年10月18日 - 空记录（无运动）
    {
      year: 2024,
      month: 10,
      day: 18,
      totalTarget: {
        stepCount: 8000,
        distance: 1000,
        deplete: 600,
        timeLength: 1800
      },
      totalStepCount: 0,
      totalDistance: 0,
      totalDeplete: 0,
      totalSportTimeLength: 0,
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: []
    },
    // 2024年5月1日 - 空记录（无运动）
    {
      year: 2024,
      month: 5,
      day: 1,
      totalTarget: {
        stepCount: 8000,
        distance: 10000,
        deplete: 600,
        timeLength: 1800
      },
      totalStepCount: 0,
      totalDistance: 0,
      totalDeplete: 0,
      totalSportTimeLength: 0,
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: []
    },
    // 2025年11月1日 - 用于月对比（11月数据）
    {
      year: 2025,
      month: 11,
      day: 1,
      totalTarget: {
        stepCount: 10000,
        distance: 15000,
        deplete: 400,
        timeLength: 1800
      },
      totalStepCount: 4400, // 计时运动20分钟(2200) + 健走20分钟(2200)
      totalDistance: 3080, // 计时运动20分钟(1540) + 健走20分钟(1540)
      totalDeplete: 174, // 计时运动20分钟(87) + 健走20分钟(87)
      totalSportTimeLength: 2400, // 20+20 = 40分钟 = 2400秒
      // 根据sportItemList的hour和minute精确分配：7:00计时20分钟(7点)、13:00健走20分钟(13点)
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 2200, 0, 0, 0, 0, 0, 2200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 1540, 0, 0, 0, 0, 1540, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 87, 0, 0, 0, 0, 87, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 1200, 0, 0, 0, 0, 1200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
        {
          type: SportType.CLOCK_BASE_EXCERCISE,
          childType: ChildSportType.TIMING_SPORT,
          hour: 7,
          minute: 0,
          distance: 1540,
          timeLength: 1200,
          deplete: 87,
          target: {
            targetType: TargetType.TIME_LENGTH,
            value: 1200
          },
          stepCount: 2200
        },
        {
          type: SportType.WALKING,
          childType: ChildSportType.FREE_WALKING,
          hour: 13,
          minute: 0,
          distance: 1540,
          timeLength: 1200,
          deplete: 87,
          stepCount: 2200,
          locusPoints: MockSportRecord.dummyLocusPoints
        },
      ]
    },
    // 2025年11月3日 - 用于周对比（同一周不同天）
    {
      year: 2025,
      month: 11,
      day: 3,
      totalTarget: {
        stepCount: 12000,
        distance: 18000,
        deplete: 450,
        timeLength: 1800
      },
      totalStepCount: 6000, // 健走25分钟(2750) + 跑步25分钟(3750)
      totalDistance: 5675, // 健走25分钟(1925) + 跑步25分钟(3375)
      totalDeplete: 352, // 健走25分钟(108) + 跑步25分钟(244)
      totalSportTimeLength: 3000, // 25+25 = 50分钟 = 3000秒
      // 根据sportItemList的hour和minute精确分配：8:00健走25分钟(8点)、11:00跑步25分钟(11点)
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 2750, 0, 0, 3750, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 1925, 0, 0, 3375, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 108, 0, 0, 244, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 1500, 0, 0, 1500, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
        {
          type: SportType.WALKING,
          childType: ChildSportType.TARGET_WALKING,
          hour: 8,
          minute: 0,
          distance: 1925,
          timeLength: 1500,
          deplete: 108,
          target: {
            targetType: TargetType.DISTANCE,
            value: 2000
          },
          stepCount: 2750,
          locusPoints: MockSportRecord.dummyLocusPoints
        },
        {
          type: SportType.JOGGING,
          childType: ChildSportType.TARGET_JOGGING,
          hour: 11,
          minute: 0,
          distance: 3375,
          timeLength: 1500,
          deplete: 244,
          target: {
            targetType: TargetType.DISTANCE,
            value: 3500
          },
          stepCount: 3750,
          locusPoints: MockSportRecord.dummyLocusPoints1
        }
      ]
    },
    // 2025年10月28日 - 用于月对比（10月数据）- 健走20分钟 + 跑步15分钟（总计35分钟）
    {
      year: 2025,
      month: 10,
      day: 28,
      totalTarget: {
        stepCount: 8000,
        distance: 12000,
        deplete: 350,
        timeLength: 1800
      },
      totalStepCount: 4450, // 健走20分钟(2200) + 跑步15分钟(2250)
      totalDistance: 3565, // 健走20分钟(1540) + 跑步15分钟(2025)
      totalDeplete: 233, // 健走20分钟(87) + 跑步15分钟(146)
      totalSportTimeLength: 2100, // 20+15 = 35分钟 = 2100秒
      // 根据sportItemList的hour和minute精确分配：9:00健走20分钟(9点)、12:00跑步15分钟(12点)
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 2200, 0, 0, 2250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1540, 0, 0, 2025, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 87, 0, 0, 146, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 1200, 0, 0, 900, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      sportItemList: [
        {
          type: SportType.WALKING,
          childType: ChildSportType.FREE_WALKING,
          hour: 9,
          minute: 0,
          distance: 1540,
          timeLength: 1200,
          deplete: 87,
          stepCount: 2200,
          locusPoints: MockSportRecord.dummyLocusPoints
        },
        {
          type: SportType.JOGGING,
          childType: ChildSportType.TARGET_JOGGING,
          hour: 12,
          minute: 0,
          distance: 2025,
          timeLength: 900,
          deplete: 146,
          target: {
            targetType: TargetType.DISTANCE,
            value: 2000
          },
          stepCount: 2250,
          locusPoints: MockSportRecord.dummyLocusPoints1
        }
      ]
    },
    // 2025年10月29日 - 用于周对比（同一周不同天）- 健走25分钟（总计25分钟）
    {
      year: 2025,
      month: 10,
      day: 29,
      totalTarget: {
        stepCount: 9000,
        distance: 14000,
        deplete: 380,
        timeLength: 1800
      },
      totalStepCount: 2750, // 健走25分钟(2750)
      totalDistance: 1925, // 健走25分钟(1925)
      totalDeplete: 108, // 健走25分钟(108)
      totalSportTimeLength: 1500, // 25分钟 = 1500秒
      // 根据sportItemList的hour和minute精确分配：19:00健走25分钟(19点)
      hourStepCount: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2750, 0, 0, 0, 0],
      hourDistance: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1925, 0, 0, 0, 0],
      hourDeplete: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 108, 0, 0, 0, 0],
      hourSportTimeLength: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1500, 0, 0, 0, 0],
      sportItemList: [
        {
          type: SportType.WALKING,
          childType: ChildSportType.TARGET_WALKING,
          hour: 19,
          minute: 0,
          distance: 1925,
          timeLength: 1500,
          deplete: 108,
          target: {
            targetType: TargetType.DISTANCE,
            value: 2000
          },
          stepCount: 2750,
          locusPoints: MockSportRecord.dummyLocusPoints
        }
      ]
    }
  ]
}